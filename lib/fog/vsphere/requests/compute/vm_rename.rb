module Fog
  module Vsphere
    class Compute
      class Real
        def vm_rename(options = {})
          raise ArgumentError, 'name is a required parameter' unless options.key? 'name'
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'
          vm_mob_ref = get_vm_ref(options['instance_uuid'])
          task = vm_mob_ref.Rename_Task(newName: options['name'])
          task.wait_for_completion
          { 'task_state' => task.info.state }
        end
      end

      class Mock
        def vm_rename(options = {})
          raise ArgumentError, 'name is a required parameter' unless options.key? 'name'
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'
          { 'task_state' => 'success' }
        end
      end
    end
  end
end
