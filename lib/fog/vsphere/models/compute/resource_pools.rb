module Fog
  module Vsphere
    class Compute
      class ResourcePools < Fog::Collection
        autoload :ResourcePool, File.expand_path('../resource_pool', __FILE__)

        model Fog::Vsphere::Compute::ResourcePool
        attr_accessor :datacenter, :cluster

        def all(filters = {})
          load service.list_resource_pools(filters.merge(datacenter: datacenter, cluster: cluster))
        end

        def get(id)
          requires :datacenter
          requires :cluster
          new service.get_resource_pool(id, cluster, datacenter)
        end
      end
    end
  end
end
