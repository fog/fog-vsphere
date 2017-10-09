module Fog
  module Compute
    class Vsphere
      class Real

        def host_finish_maintenance(name, cluster_name, datacenter_name, timeout = 0)
          host_ref = get_host(name, cluster_name, datacenter_name)
          task = host_ref.ExitMaintenanceMode_Task(:timeout => timeout)
          task.wait_for_completion
          { 'task_state' => task.info.state }
        end

        protected

        def get_raw_host(name, cluster_name, datacenter_name)
          cluster = get_raw_cluster(cluster_name, datacenter_name)
          cluster.host.find { |host| host.name == name } or
                        raise Fog::Compute::Vsphere::NotFound, "no such host #{name}"
        end
      end
    end
  end
end
