module Fog
  module Vsphere
    class Compute
      class Cluster < Fog::Model
        identity :id

        attribute :name
        attribute :datacenter
        attribute :num_host
        attribute :num_cpu_cores
        attribute :overall_status
        attribute :full_path

        def resource_pools(filters = {})
          attributes[:resource_pools] ||= id.nil? ? [] : service.resource_pools({
            service: service,
            cluster: full_path,
            datacenter: datacenter
          }.merge(filters))
        end

        def datastores(filters = {})
          attributes[:datastores] ||= id.nil? ? [] : service.datastores({
            service: service,
            cluster: full_path,
            datacenter: datacenter
          }.merge(filters))
        end

        def networks(filters = {})
          attributes[:networks] ||= id.nil? ? [] : service.networks({
            service: service,
            cluster: full_path,
            datacenter: datacenter
          }.merge(filters))
        end

        def rules
          service.rules(datacenter: datacenter, cluster: full_path)
        end

        def hosts
          service.hosts(datacenter: datacenter, cluster: full_path)
        end

        def to_s
          name
        end
      end
    end
  end
end
