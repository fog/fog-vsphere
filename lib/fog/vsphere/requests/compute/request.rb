require 'fog/vsphere/requests/request'

module Fog
  module Vsphere
    module Requests
      module Compute
        class Request < Fog::Vsphere::Requests::Request
          def raw_datacenters(folder = nil)
            folder ||= connection.rootFolder
            @raw_datacenters ||= get_raw_datacenters_from_folder folder
          end

          def find_raw_datacenter(name)
            raw_datacenters.find { |d| d.name == name } || get_raw_datacenter(name)
          end

          def get_raw_cluster(name, datacenter_name_or_obj)
            dc = if datacenter_name_or_obj.is_a?(String)
                   find_raw_datacenter(datacenter_name_or_obj)
                 else
                   datacenter_name_or_obj
                 end
            dc.find_compute_resource(name)
          end

          def get_raw_host(name, cluster_name, datacenter_name)
            cluster = get_raw_cluster(cluster_name, datacenter_name)
            cluster.host.find { |host| host.name == name } ||
              raise(Fog::Vsphere::Compute::NotFound, "no such host #{name}")
          end

          def get_raw_resource_pool(name, cluster_name, datacenter_name)
            dc      = find_raw_datacenter(datacenter_name)
            cluster = dc.find_compute_resource(cluster_name)
            name.nil? ? cluster.resourcePool : cluster.resourcePool.traverse(name)
          end

          # Folders

          def get_raw_folder(path, datacenter_name_or_obj, type)
            # The required path syntax - 'topfolder/subfolder

            # Clean up path to be relative since we're providing datacenter name
            dc = if datacenter_name_or_obj.is_a?(String)
                   find_raw_datacenter(datacenter_name_or_obj)
                 else
                   datacenter_name_or_obj
                 end

            valid_types = %w[vm network datastore host]
            raise ArgumentError, "#{type} is unknown" if type.nil? || type.empty?
            raise "Invalid type (#{type}). Must be one of #{valid_types.join(', ')} " unless valid_types.include?(type.to_s)
            meth = "#{type}Folder"
            dc_root_folder = dc.send(meth)

            # Filter the root path for this datacenter not to be used."
            dc_root_folder_path = dc_root_folder.path.map { |_, name| name }.join('/')
            paths = path.sub(/^\/?#{Regexp.quote(dc_root_folder_path)}\/?/, '').split('/')

            return dc_root_folder if paths.empty?
            # Walk the tree resetting the folder pointer as we go
            paths.reduce(dc_root_folder) do |last_returned_folder, sub_folder|
              # JJM VIM::Folder#find appears to be quite efficient as it uses the
              # searchIndex It certainly appears to be faster than
              # VIM::Folder#inventory since that returns _all_ managed objects of
              # a certain type _and_ their properties.
              sub = last_returned_folder.find(sub_folder, RbVmomi::VIM::Folder)
              raise Fog::Vsphere::Compute::NotFound, "Could not descend into #{sub_folder}.  Please check your path. #{path}" unless sub
              sub
            end
          end

          def get_raw_vmfolder(path, datacenter_name)
            get_raw_folder(path, datacenter_name, 'vm')
          end

          # Datastores

          def get_raw_datastore(name, datacenter_name)
            get_raw_datastores(datacenter_name).detect { |ds| ds.name == name }
          end

          def get_raw_datastores(datacenter_name)
            list_container_view(datacenter_name, 'Datastore', :datastoreFolder)
          end

          # Storage pods

          def raw_storage_pods(datacenter_name)
            list_container_view(datacenter_name, 'StoragePod')
          end

          def get_raw_storage_pod(name, datacenter_name)
            raw_storage_pods(datacenter_name).detect { |pod| pod.name == name }
          end

          # Networks

          def get_raw_network(ref_or_name, datacenter_name, distributedswitch = nil)
            finder = choose_network_finder(ref_or_name, distributedswitch)
            get_all_raw_networks(datacenter_name).find { |n| finder.call(n) }
          end

          def get_all_raw_networks(datacenter_name)
            list_container_view(datacenter_name, 'Network', :networkFolder)
          end

          def choose_network_finder(ref_or_name, distributedswitch)
            case distributedswitch
            when String
              # only the one will do
              proc do |n|
                n._ref == ref_or_name || (
                  n.is_a?(RbVmomi::VIM::DistributedVirtualPortgroup) && (n.name == ref_or_name || n.key == ref_or_name) &&
                  (n.config.distributedVirtualSwitch.name == distributedswitch)
                )
              end
            when :dvs
              # the first distributed virtual switch will do - selected by network - gives control to vsphere
              proc do |n|
                n._ref == ref_or_name || (
                  n.is_a?(RbVmomi::VIM::DistributedVirtualPortgroup) && (n.name == ref_or_name || n.key == ref_or_name)
                )
              end
            else
              # the first matching network will do, seems like the non-distributed networks come first
              proc { |n| n._ref == ref_or_name || n.name == ref_or_name || (n.is_a?(RbVmomi::VIM::DistributedVirtualPortgroup) && n.key == ref_or_name) }
            end
          end

          private

          def get_raw_datacenters_from_folder(folder = nil)
            folder.childEntity.map do |child|
              if child.is_a? RbVmomi::VIM::Datacenter
                child
              elsif child.is_a? RbVmomi::VIM::Folder
                get_raw_datacenters_from_folder child
              end
            end.flatten
          end

          def list_container_view(datacenter_obj_or_name, type, container_object = nil)
            dc = if datacenter_obj_or_name.is_a?(String)
                   find_raw_datacenter(datacenter_obj_or_name)
                 else
                   datacenter_obj_or_name
                 end

            container = if container_object
                          dc.public_send(container_object)
                        else
                          dc
                        end

            container_view = connection.serviceContent.viewManager.CreateContainerView(
              container: dc,
              type: [type],
              recursive: true
            )

            result = container_view.view
            container_view.DestroyView
            result
          end
        end
      end
    end
  end
end
