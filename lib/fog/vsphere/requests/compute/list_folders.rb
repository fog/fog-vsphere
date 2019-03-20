module Fog
  module Vsphere
    class Compute
      class Real
        # Grabs all sub folders within a given path folder.
        #
        # ==== Parameters
        # * filters<~Hash>:
        #   * :datacenter<~String> - *REQUIRED* Your datacenter where you're
        #     looking for folders. Example: 'my-datacenter-name' (passed if you
        #     are using the models/collections)
        #       eg: vspconn.datacenters.first.vm_folders('mypath')
        #   * :path<~String> - Your path where you're looking for
        #     more folders, if return = none you will get an error. If you don't
        #     define it will look in the main datacenter folder for any folders
        #     in that datacenter.
        #
        # Example Usage Testing Only:
        #  vspconn = Fog::Compute[:vsphere]
        #  mydc = vspconn.datacenters.first
        #  folders = mydc.vm_folders
        #
        def list_folders(filters = {})
          path            = filters[:path] || filters['path'] || ''
          datacenter_name = filters[:datacenter]

          # if we don't need to display folders for a specific path
          # we can easily use a property collector to get the
          # data in an efficient manner from vsphere
          # otherwise we use a much slower implementation
          unless path.nil? || path.empty?
            return get_raw_vmfolders(path, datacenter_name).map do |folder|
              folder_attributes(folder, datacenter_name)
            end
          end

          root_folder = connection.serviceContent.rootFolder

          results = property_collector_results(folder_filter_spec(root_folder))

          folder_inventory = generate_folder_inventory(results)

          folders = results.select { |result| result.obj.is_a?(RbVmomi::VIM::Folder) && result['childType'].include?('VirtualMachine') }

          folders.map do |folder|
            folder_id = managed_obj_id(folder.obj)
            parent_id = folder['parent']._ref if folder['parent']
            path = lookup_folder_path(folder_inventory, folder_id)
            next unless path.include?(datacenter_name) # skip folders from another datacenter
            map_attrs_to_hash(folder, folder_attribute_mapping).merge(
              datacenter: datacenter_name,
              parent: lookup_folder_name(folder_inventory, parent_id),
              path: path.join('/'),
              type: folder_type(folder['childType']),
              id: folder_id
            )
          end.compact
        end

        protected

        def folder_filter_spec(root_folder)
          RbVmomi::VIM.PropertyFilterSpec(
            objectSet: [
              obj: root_folder,
              skip: false,
              selectSet: [
                dc_folder_traversal_spec,
                datacenter_to_vm_folder_traversal_spec
              ]
            ],
            propSet: [
              { type: 'Folder', pathSet: folder_attribute_mapping.values + %w[parent childType] },
              { type: 'Datacenter', pathSet: %w[name parent] }
            ]
          )
        end

        def dc_folder_traversal_spec
          RbVmomi::VIM.TraversalSpec(
            name: 'dcFolderTraversalSpec',
            type: 'Folder',
            path: 'childEntity',
            skip: false,
            selectSet: [
              RbVmomi::VIM.SelectionSpec(name: 'dcFolderTraversalSpec'),
              RbVmomi::VIM.SelectionSpec(name: 'DatacenterToVmFolderTraversalSpec')
            ]
          )
        end

        def datacenter_to_vm_folder_traversal_spec
          RbVmomi::VIM.TraversalSpec(
            name: 'DatacenterToVmFolderTraversalSpec',
            type: 'Datacenter',
            path: 'vmFolder',
            skip: false,
            selectSet: [
              RbVmomi::VIM.SelectionSpec(name: 'dcFolderTraversalSpec')
            ]
          )
        end

        def lookup_folder_name(inventory, folder_id)
          folder = inventory[folder_id]
          return '' unless folder
          folder[:name]
        end

        def lookup_folder_path(inventory, folder_id)
          folder = inventory[folder_id]
          return '' unless folder
          folder[:path]
        end

        def set_folder_paths(folder_inventory) # rubocop:disable Naming/AccessorMethodName
          folder_inventory.each do |ref, props|
            props[:path] = ['', lookup_parent_folders(folder_inventory, ref).reverse].flatten
          end
        end

        def lookup_parent_folders(folder_inventory, ref)
          return [] unless folder_inventory[ref]
          return [folder_inventory[ref][:name]] if folder_inventory[ref][:parent].nil?
          [folder_inventory[ref][:name], lookup_parent_folders(folder_inventory, folder_inventory[ref][:parent])].flatten
        end

        def folder_attribute_mapping
          {
            name: 'name'
          }
        end

        def generate_folder_inventory(folders)
          folder_inventory = folders.each_with_object({}) do |folder, inventory|
            parent = if folder['parent'].nil?
                       nil
                     else
                       folder['parent']._ref
                     end
            inventory[folder.obj._ref] = {
              name: folder['name'],
              parent: parent
            }
          end
          set_folder_paths(folder_inventory)
          folder_inventory
        end

        def get_raw_vmfolders(path, datacenter_name)
          folder = get_raw_vmfolder(path, datacenter_name)
          child_folders(folder).flatten.compact
        end

        def child_folders(folder)
          [folder, folder.childEntity.grep(RbVmomi::VIM::Folder).map(&method(:child_folders)).flatten]
        end
      end
      class Mock
        def list_folders(options = {})
          options.reject! { |_k, v| v.nil? } # ignore options with nil value
          data[:folders].values.select { |folder| options.all? { |k, v| folder[k.to_s] == v.to_s } }
        end
      end
    end
  end
end
