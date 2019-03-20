module Fog
  module Vsphere
    class Compute
      class Real
        def host_shutdown(name, cluster_name, datacenter_name, force = false)
          host_ref = get_host(name, cluster_name, datacenter_name)
          task = host_ref.ShutdownHost_Task(force: force)
          task.wait_for_completion
          { 'task_state' => task.info.state }
        end
      end
    end
  end
end
