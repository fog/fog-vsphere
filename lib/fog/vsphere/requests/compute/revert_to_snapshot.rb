module Fog
  module Vsphere
    class Compute
      class Real
        def revert_to_snapshot(snapshot)
          unless Snapshot === snapshot
            raise ArgumentError, 'snapshot is a required parameter'
          end

          task = snapshot.mo_ref.RevertToSnapshot_Task
          task.wait_for_completion

          {
            'state' => task.info.state
          }
        end
      end

      class Mock
        def revert_to_snapshot(snapshot)
          raise ArgumentError, 'snapshot is a required parameter' if snapshot.nil?

          {
            'state' => 'success'
          }
        end
      end
    end
  end
end
