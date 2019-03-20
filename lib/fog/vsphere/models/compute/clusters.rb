module Fog
  module Vsphere
    class Compute
      class Clusters < Fog::Collection
        autoload :Cluster, File.expand_path('../cluster', __FILE__)

        model Fog::Vsphere::Compute::Cluster
        attr_accessor :datacenter

        def all(filters = {})
          requires :datacenter
          load service.list_clusters(filters.merge(datacenter: datacenter))
        end

        def get(id)
          requires :datacenter
          new service.get_cluster(id, datacenter)
        end
      end
    end
  end
end
