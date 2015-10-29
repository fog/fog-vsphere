module Fog
  module Compute
    class Vsphere
      class Networks < Fog::Collection
        autoload :Network, File.expand_path('../network', __FILE__)

        model Fog::Compute::Vsphere::Network
        attr_accessor :datacenter

        def all(filters = {})
          f = { :datacenter => datacenter }.merge(filters)
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
