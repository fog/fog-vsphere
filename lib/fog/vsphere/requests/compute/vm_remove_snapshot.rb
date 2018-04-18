module Fog
  module Compute
    class Vsphere
      class Real
        def vm_remove_snapshot(vm_id, snapshot_id, remove_children = false)
          vm = servers.get(vm_id)
          snapshot = vm.snapshots.get(snapshot_id).mo_ref
          task = snapshot.RemoveSnapshot_Task(removeChildren: remove_children)

          task.wait_for_completion

          {
            'task_state' => task.info.state,
            'was_cancelled' => task.info.cancelled
          }
        end
      end

      class Mock
        def vm_remove_snapshot(_vm_id, _snapshot_id)
          {
            'task_state' => 'success',
            'was_cancelled' => false
          }
        end
      end
    end
  end
end
