module Fog
  module Vsphere
    class Compute
      class Real
        def list_resource_pools(filters = {})
          datacenter_name = filters[:datacenter]
          cluster_name    = filters[:cluster]
          cluster         = get_raw_cluster(cluster_name, datacenter_name)
          list_raw_resource_pools(cluster).map do |resource_pool|
            resource_pool_attributes(resource_pool, cluster_name, datacenter_name)
          end
        end

        protected

        # root ResourcePool + Children if they exists
        def list_raw_resource_pools(cluster)
          pools = []
          traverse_raw_resource_pools(pools, cluster.resourcePool)
          pools.uniq
        end

        def traverse_raw_resource_pools(pools, rp)
          if rp
            if rp.respond_to? :resourcePool
              traverse_raw_resource_pools(pools, rp.resourcePool)
            end
            if rp.respond_to? :each
              rp.each do |resourcePool|
                traverse_raw_resource_pools(pools, resourcePool)
              end
            else
              pools << rp
            end
          end
        end

        def resource_pool_attributes(resource_pool, cluster, datacenter)
          folder_path(resource_pool) =~ /(?<=Resources\/)(.+)/
          name = Regexp.last_match(1) || 'Resources'
          {
            id: managed_obj_id(resource_pool),
            name: name,
            configured_memory_mb: resource_pool.summary.configuredMemoryMB,
            overall_status: resource_pool.overallStatus,
            cluster: cluster,
            datacenter: datacenter
          }
        end
      end

      class Mock
        def list_resource_pools(filters = {}); end
      end
    end
  end
end
