module Fog
  module Vsphere
    class Compute
      class Real
        def get_host(name, cluster_name, datacenter_name)
          get_raw_host(name, cluster_name, datacenter_name)
        end

        protected

        def get_raw_host(name, cluster_name, datacenter_name)
          shared_request.get_raw_host(name, cluster_name, datacenter_name)
        end
      end
    end
  end
end
