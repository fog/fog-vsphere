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
        #   * 'host'<~String> - name of host which will run the VM.
        #   * 'pool'<~String> - name of pool which the VM should be
        #       attached.
        #   * 'disks'<~Array> - disks to relocate. Each disk is a
        #       hash with diskId wich is key attribute of volume,
        #       and datastore to relocate to.
        def vm_relocate(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'

          # Find the VM Object
          search_filter = { :uuid => options['instance_uuid'], 'vmSearch' => true, 'instanceUuid' => true }
          vm_mob_ref = connection.searchIndex.FindAllByUuid(search_filter).first

          unless vm_mob_ref.is_a? RbVmomi::VIM::VirtualMachine
            raise Fog::Vsphere::Errors::NotFound,
                  "Could not find VirtualMachine with instance uuid #{options['instance_uuid']}"
          end
          options['host'] = get_raw_host(options['host'], options['cluster'], options['datacenter']) if options['host']
          if options['disks']
            options['disks'] = options['disks'].map do |disk|
              disk['datastore'] = get_raw_datastore(disk['datastore'], nil)
              RbVmomi::VIM::VirtualMachineRelocateSpecDiskLocator(disk)
            end
          end
          spec = RbVmomi::VIM::VirtualMachineRelocateSpec(
            pool: options['pool'],
            host: options['host'],
            disk: options['disks']
          )
          task = vm_mob_ref.RelocateVM_Task(spec: spec, priority: options['priority'])
          task.wait_for_completion
          { 'task_state' => task.info.state }
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
