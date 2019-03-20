module Fog
  module Vsphere
    class Compute
      class Real
        def vm_suspend(options = {})
          raise(ArgumentError, 'instance_uuid is a required parameter') unless options.key?('instance_uuid')
          options = { 'force' => false }.merge(options)

          search_filter = { :uuid => options['instance_uuid'], 'vmSearch' => true, 'instanceUuid' => true }
          vm = connection.searchIndex.FindAllByUuid(search_filter).first

          if options['force']
            suspend_forcefully(vm)
          else
            suspend_gracefully(vm)
          end
        end

        private

        def suspend_forcefully(vm)
          task = vm.SuspendVM_Task
          task.wait_for_completion
          {
            'task_state'   => task.info.result,
            'suspend_type' => 'suspend'
          }
        end

        def suspend_gracefully(vm)
          vm.StandbyGuest
          {
            'task_state'   => 'running',
            'suspend_type' => 'standby_guest'
          }
        end
      end

      class Mock
        def vm_suspend(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'

          vm = get_virtual_machine(options['instance_uuid'])
          vm['power_state'] = 'suspended'

          {
            'task_state'   => 'running',
            'suspend_type' => options['force'] ? 'suspend' : 'standby_guest'
          }
        end
      end
    end
  end
end
