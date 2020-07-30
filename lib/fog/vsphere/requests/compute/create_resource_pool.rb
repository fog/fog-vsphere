module Fog
  module Vsphere
    class Compute
      class Real
        def create_resource_pool(attributes = {})
          cluster = get_raw_cluster(attributes[:cluster], attributes[:datacenter])

          root_resource_pool = if attributes[:root_resource_pool_name]
                                 cluster.resourcePool.find attributes[:root_resource_pool_name].gsub('/', '%2f')
                               else
                                 cluster.resourcePool
                               end

          raise ArgumentError, 'Root resource pool could not be found' if root_resource_pool.nil?

          resource_pool = root_resource_pool.CreateResourcePool(
            name: attributes[:name],
            spec: get_resource_pool_spec(attributes)
          )

          resource_pool_attributes(resource_pool, attributes[:cluster], attributes[:datacenter])
        end

        private

        def get_resource_pool_spec(attributes = {})
          RbVmomi::VIM.ResourceConfigSpec(
            cpuAllocation: get_resource_pool_allocation_spec(attributes.fetch(:cpu, {})),
            memoryAllocation: get_resource_pool_allocation_spec(attributes.fetch(:memory, {}))
          )
        end

        def get_resource_pool_allocation_spec(attributes = {})
          RbVmomi::VIM.ResourceAllocationInfo(
            reservation: attributes.fetch(:reservation, 0),
            limit: attributes.fetch(:limit, -1),
            expandableReservation: attributes.fetch(:expandable_reservation, false),
            shares: RbVmomi::VIM.SharesInfo(
              level: RbVmomi::VIM.SharesLevel(attributes.fetch(:shares_level, 'normal')),
              shares: attributes.fetch(:shares, 0)
            )
          )
        end
      end

      class Mock
        def create_resource_pool(attributes = {}); end
      end
    end
  end
end
