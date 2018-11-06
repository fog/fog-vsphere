module Fog
  module Compute
    class Vsphere
      class Real
        # Clones a VM from a template or existing machine on your vSphere
        # Server.
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'instance_uuid'<~String> - *REQUIRED* VM to relocate
        #   * 'host'<~Array> - name of host and cluster which will run
        #     the VM. Only works with clusters within same datacenter
        #     as where vm is running.
        #     Example: ['cluster_name_here','host_name_here']
        #   * 'datastore'<~String> - name of datastore where VM will
        #     located.
        #   * 'resource_pool'<~Array> - The resource pool on your datacenter
        #     cluster you want to use. Only works with clusters within same
        #     datacenter as where vm is running.
        #     Example: ['cluster_name_here','resource_pool_name_here']
        #   * 'disks'<~Array> - disks to relocate. Each disk is a
        #     hash with diskId wich is key attribute of volume,
        #     and datastore to relocate to. diskBackingInfo can be provided,
        #     with type FlatVer2 or SeSparse
        #     Example: [{
        #       'diskId' => 2000,
        #       'datastore' => 'datastore_name',
        #       'diskBackingInfo' => {'type' => 'FlatVer2', ...}
        #     }]
        def vm_relocate(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'

          # Find the VM Object
          search_filter = { :uuid => options['instance_uuid'], 'vmSearch' => true, 'instanceUuid' => true }
          vm_mob_ref = connection.searchIndex.FindAllByUuid(search_filter).first

          unless vm_mob_ref.is_a? RbVmomi::VIM::VirtualMachine
            raise Fog::Vsphere::Errors::NotFound,
                  "Could not find VirtualMachine with instance uuid #{options['instance_uuid']}"
          end
          datacenter = get_vm_datacenter(vm_mob_ref)

          options['host'] = get_raw_host(options['host'][1], options['host'][0], datacenter) if options['host']

          options['datastore'] = get_raw_datastore(options['datastore'], datacenter) if options.key?('datastore')

          if ( options.key?('resource_pool') && options['resource_pool'].is_a?(Array) && options['resource_pool'].length == 2 && options['resource_pool'][1] != 'Resources')
            cluster_name = options['resource_pool'][0]
            pool_name = options['resource_pool'][1]
            resource_pool = get_raw_resource_pool(pool_name, cluster_name, datacenter)
          elsif ( options.key?('resource_pool') && options['resource_pool'].is_a?(Array) && options['resource_pool'].length == 2 && options['resource_pool'][1] == 'Resources')
            cluster_name = options['resource_pool'][0]
            resource_pool = get_raw_resource_pool(nil, cluster_name, datacenter)
          end

          if options['disks']
            options['disks'] = options['disks'].map do |disk|
              disk['datastore'] = get_raw_datastore(disk['datastore'], datacenter)
              if disk['diskBackingInfo'] && disk['diskBackingInfo']['type']
                backing_type = "VirtualDisk#{disk['diskBackingInfo'].delete('type')}BackingInfo"
                disk['diskBackingInfo'] = RbVmomi::VIM.send(backing_type, disk['diskBackingInfo'])
              end
              RbVmomi::VIM::VirtualMachineRelocateSpecDiskLocator(disk)
            end
          end

          spec = RbVmomi::VIM::VirtualMachineRelocateSpec(
            datastore: options['datastore'],
            pool: resource_pool,
            host: options['host'],
            disk: options['disks']
          )
          task = vm_mob_ref.RelocateVM_Task(spec: spec, priority: options['priority'])
          task.wait_for_completion
          { 'task_state' => task.info.state }
        end

        def get_vm_datacenter(vm_mob_ref)
          parent = vm_mob_ref.parent
          until parent.is_a?(RbVmomi::VIM::Datacenter)
            if vm_mob_ref.respond_to?(:parent)
              parent = parent.parent
            else
              return
            end
          end
          parent.name
        end
      end

      class Mock
        def vm_relocate(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'
          { 'task_state' => 'success' }
        end
      end
    end
  end
end
