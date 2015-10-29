module Fog
  module Compute
    class Vsphere
      class Datastores < Fog::Collection
        autoload :Datastore, File.expand_path('../datastore', __FILE__)

        model Fog::Compute::Vsphere::Datastore
        attr_accessor :datacenter

        def all(filters = {})
          load service.list_datastores(filters.merge(:datacenter => datacenter))
        end

        def get(id)
          requires :datacenter
          new service.get_datastore(id, datacenter)
        end
      end
    end
  end
end
