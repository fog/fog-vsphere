module Fog
  module Vsphere
    class Compute
      class Datastores < Fog::Collection
        model Fog::Vsphere::Compute::Datastore
        attr_accessor :datacenter, :cluster

        def all(filters = {})
          load service.list_datastores(filters.merge(datacenter: datacenter, cluster: cluster))
        end

        def get(id)
          requires :datacenter
          new service.get_datastore(id, datacenter)
        end
      end
    end
  end
end
