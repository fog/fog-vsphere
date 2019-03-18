module Fog
  module Compute
    class Vsphere
      class Real
        def list_networks(filters = {})
          datacenter_name = filters[:datacenter]
          cluster_name = filters.fetch(:cluster, nil)
          # default to show all networks
          only_active = filters[:accessible] || false

          dc = find_raw_datacenter(datacenter_name)

          results = property_collector_results(network_filter_spec(dc))

          dvswitches = results.select { |result| result.obj.is_a?(RbVmomi::VIM::DistributedVirtualSwitch) }.each_with_object({}) do |dvswitch, obj|
            obj[dvswitch.obj._ref] = dvswitch['summary.name']
          end

          if cluster_name
            cluster = get_raw_cluster(cluster_name, datacenter_name)
            cluster_networks = cluster.network.map(&:_ref)
          end

          results.select { |result| result.obj.is_a?(RbVmomi::VIM::DistributedVirtualPortgroup) || result.obj.is_a?(RbVmomi::VIM::Network) }.map do |network|
            next if cluster_name && !cluster_networks.include?(network.obj._ref)
            next if only_active && !network['summary.accessible']
            if network.obj.is_a?(RbVmomi::VIM::DistributedVirtualPortgroup)
              map_attrs_to_hash(network, network_dvportgroup_attribute_mapping).merge(
                vlanid: raw_network_vlan(network['config.defaultPortConfig']),
                virtualswitch: dvswitches[network['config.distributedVirtualSwitch']._ref]
              )
            else
              map_attrs_to_hash(network, network_attribute_mapping).merge(
                id: managed_obj_id(network.obj)
              )
            end.merge(
              datacenter: datacenter_name,
              _ref: network.obj._ref
            )
          end.compact
        end

        protected

        def network_attribute_mapping
          {
            name: 'name',
            accessible: 'summary.accessible'
          }
        end

        def network_dvportgroup_attribute_mapping
          network_attribute_mapping.merge(
            id: 'config.key'
          )
        end

        def folder_traversal_spec
          RbVmomi::VIM.TraversalSpec(
            name: 'FolderTraversalSpec',
            type: 'Folder',
            path: 'childEntity',
            skip: false,
            selectSet: [
              RbVmomi::VIM.SelectionSpec(name: 'FolderTraversalSpec')
            ]
          )
        end

        def network_filter_spec(obj)
          RbVmomi::VIM.PropertyFilterSpec(
            objectSet: [
              obj: obj.networkFolder,
              skip: true,
              selectSet: [
                folder_traversal_spec
              ]
            ],
            propSet: [
              { type: 'DistributedVirtualSwitch', pathSet: ['summary.name'] },
              { type: 'Network', pathSet: network_attribute_mapping.values },
              { type: 'DistributedVirtualPortgroup', pathSet: network_dvportgroup_attribute_mapping.values + ['config.defaultPortConfig', 'config.distributedVirtualSwitch'] }
            ]
          )
        end

        private

        def raw_network_vlan(network)
          case network
          when RbVmomi::VIM::VMwareDVSPortSetting
            raw_network_vlan_id(network.vlan)
          end
        end

        def raw_network_vlan_id(vlan)
          case vlan
          when RbVmomi::VIM::VmwareDistributedVirtualSwitchVlanIdSpec
            vlan.vlanId
          end
        end
      end

      class Mock
        def list_networks(filters)
          datacenter_name = filters[:datacenter]
          cluster_name = filters.fetch(:cluster, nil)
          if cluster_name.nil?
            data[:networks].values.select { |d| d['datacenter'] == datacenter_name } ||
              raise(Fog::Compute::Vsphere::NotFound)
          else
            data[:networks].values.select { |d| d['datacenter'] == datacenter_name && d['cluster'].include?(cluster_name) } ||
              raise(Fog::Compute::Vsphere::NotFound)
          end
        end
      end
    end
  end
end
