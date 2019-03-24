module Fog
  module Vsphere
    class Compute
      class Real
        def get_resource_pool(name, cluster_name, datacenter_name)
          resource_pool = get_raw_resource_pool(name, cluster_name, datacenter_name)
          raise(Fog::Vsphere::Compute::NotFound) unless resource_pool
          resource_pool_attributes(resource_pool, cluster_name, datacenter_name)
        end

        protected

        def get_raw_resource_pool(name, cluster_name, datacenter_name)
          shared_request.get_raw_resource_pool(name, cluster_name, datacenter_name)
        end
      end

      class Mock
        def get_resource_pool(name, cluster_name, datacenter_name); end
      end
    end
  end
end
