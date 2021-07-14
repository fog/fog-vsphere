module Fog
  module Vsphere
    class Compute
      class Real
        def vm_take_snapshot(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'
          raise ArgumentError, 'name is a required parameter' unless options.key? 'name'
          defaults = {
            description: '',
            memory: true,
            quiesce: false
          }
          opts = options.clone
          defaults.each do |k, v|
            opts[k] = v unless opts.key?(k) || opts.key?(k.to_s)
          end
          vm = get_vm_ref(options['instance_uuid'])
          task = vm.CreateSnapshot_Task(opts)

          task.wait_for_completion

          {
            'task_state' => task.info.state,
            'was_cancelled' => task.info.cancelled
          }
        end
      end

      class Mock
        def vm_take_snapshot(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'
          raise ArgumentError, 'name is a required parameter' unless options.key? 'name'
          {
            'task_state' => 'success',
            'was_cancelled' => false
          }
        end
      end
    end
  end
end
