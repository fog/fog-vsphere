module Fog
  module Vsphere
    class Compute
      class Real
        def host_finish_maintenance(name, cluster_name, datacenter_name, timeout = 0)
          host_ref = get_host(name, cluster_name, datacenter_name)
          task = host_ref.ExitMaintenanceMode_Task(timeout: timeout)
          task.wait_for_completion
          { 'task_state' => task.info.state }
        end
      end
    end
  end
end
