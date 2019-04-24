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
          shared_request.get_raw_folder(path, datacenter_name_or_obj, type)
        end

        def get_raw_vmfolder(path, datacenter_name)
          shared_request.get_raw_folder(path, datacenter_name, 'vm')
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
