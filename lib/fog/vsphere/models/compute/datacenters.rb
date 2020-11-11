module Fog
  module Vsphere
    class Compute
      class Datacenters < Fog::Collection
        model Fog::Vsphere::Compute::Datacenter

        def all(filters = {})
          load service.list_datacenters(filters)
        end

        def get(name)
          new service.get_datacenter(name)
        end
      end
    end
  end
end
