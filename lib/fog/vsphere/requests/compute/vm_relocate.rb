module Fog
  module Vsphere
    class Compute
      class Real
        # Relocates a VM to different host or datastore.
        #
        # ==== Parameters
        # * options<~Hash>:
        #   * 'instance_uuid'<~String> - *REQUIRED* VM to relocate
        #   * 'host'<~String> - name of host which will run the VM.
        #   * 'cluster'<~String> - name of cluster where host is.
        #       Only works with clusters within same datacenter as
        #       where vm is running. Defaults to vm's host's cluster.
        #   * 'datacenter'<~String> - name of datacenter where host is.
        #       It must be same datacenter as where vm is running.
        #       Defaults to vm's datacenter.
        #   * 'datastore'<~String> - name of datastore where VM will
        #       be located.
        #   * 'pool'<~String> - name of pool which the VM should be
        #       attached.
        #   * 'disks'<~Array> - disks to relocate. Each disk is a
        #       hash with diskId wich is key attribute of volume,
        #       and datastore to relocate to. diskBackingInfo can be provided,
        #       with type FlatVer2 or SeSparse
        #       Example: [{
        #         'diskId' => 2000,
        #         'datastore' => 'datastore_name',
        #         'diskBackingInfo' => {'type' => 'FlatVer2', ...}
        #       }]
        def vm_relocate(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'

          # Find the VM Object
          search_filter = { :uuid => options['instance_uuid'], 'vmSearch' => true, 'instanceUuid' => true }
          vm_mob_ref = connection.searchIndex.FindAllByUuid(search_filter).first

          unless vm_mob_ref.is_a? RbVmomi::VIM::VirtualMachine
            raise Fog::Vsphere::Errors::NotFound,
                  "Could not find VirtualMachine with instance uuid #{options['instance_uuid']}"
          end
          datacenter = options['datacenter'] || get_vm_datacenter(vm_mob_ref)
          cluster_name = options['cluster'] || get_vm_cluster(vm_mob_ref)

          options['host'] = get_raw_host(options['host'], cluster_name, datacenter) if options['host']
          options['datastore'] = get_raw_datastore(options['datastore'], datacenter) if options.key?('datastore')

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
            pool: options['pool'],
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

        def get_vm_cluster(vm_mob_ref)
          parent = vm_mob_ref.runtime.host.parent
          until parent.is_a?(RbVmomi::VIM::ClusterComputeResource)
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
