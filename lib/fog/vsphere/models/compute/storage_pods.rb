require 'fog/core/collection'
require 'fog/vsphere/models/compute/storage_pod'

module Fog
  module Vsphere
    class Compute
      class StoragePods < Fog::Collection
        model Fog::Vsphere::Compute::StoragePod
        attribute :datacenter

        def all(filters = {})
          load service.list_storage_pods(filters.merge(datacenter: datacenter))
        end

        def get(id)
          requires :datacenter
          new service.get_storage_pod(id, datacenter)
        end
      end
    end
  end
end
