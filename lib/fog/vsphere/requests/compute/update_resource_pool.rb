module Fog
  module Vsphere
    class Compute
      class Real
        def update_resource_pool(attributes = {})
          raw_resource_pool = get_raw_resource_pool_by_ref(attributes)

          raw_resource_pool.UpdateConfig(
            name: attributes[:name],
            config: get_resource_pool_spec(attributes)
          )

          resource_pool_attributes(raw_resource_pool, attributes[:cluster], attributes[:datacenter])
        end

        private

        def get_raw_resource_pool_by_ref(attributes = {})
          dc = find_raw_datacenter(attributes[:datacenter])
          cluster = dc.find_compute_resource(attributes[:cluster])

          list_raw_resource_pools(cluster).detect { |rp| rp._ref == attributes[:ref] }
        end
      end

      class Mock
        def update_resource_pool(attributes = {}); end
      end
    end
  end
end
