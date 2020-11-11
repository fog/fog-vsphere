module Fog
  module Vsphere
    class Compute
      class Networks < Fog::Collection
        model Fog::Vsphere::Compute::Network
        attr_accessor :datacenter, :cluster

        def all(filters = {})
          f = { datacenter: datacenter, cluster: cluster }.merge(filters)
          load service.list_networks(f)
        end

        def get(id)
          requires :datacenter
          new service.get_network(id, datacenter)
        end
      end
    end
  end
end
