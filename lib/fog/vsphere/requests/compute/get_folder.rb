module Fog
  module Vsphere
    class Compute
      class Real
        def get_folder(path, datacenter_name, type = nil)
          type ||= 'vm'
          # Cycle through all types of folders.
          folder = get_raw_folder(path, datacenter_name, type)
          raise(Fog::Vsphere::Compute::NotFound) unless folder
          folder_attributes(folder, datacenter_name)
        end

        protected

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

        def folder_attributes(folder, datacenter_name)
          {
            id: managed_obj_id(folder),
            name: folder.name,
            parent: folder.parent.name,
            datacenter: datacenter_name,
            type: folder_type(folder.childType),
            path: folder_path(folder)
          }
        end

        def folder_path(folder)
          '/' + folder.path.map(&:last).join('/')
        end

        def folder_type(types)
          return :vm        if types.include?('VirtualMachine')
          return :network   if types.include?('Network')
          return :datastore if types.include?('Datastore')
          return :host      if types.include?('ComputeResource')
        end
      end

      class Mock
        def get_folder(path, datacenter_name, _type = nil)
          data[:folders].values.find { |f| (f['datacenter'] == datacenter_name) && f['path'].end_with?(path) } ||
            raise(Fog::Vsphere::Compute::NotFound)
        end
      end
    end
  end
end
