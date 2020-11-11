module Fog
  module Vsphere
    class Compute
      class Rules < Fog::Collection
        model Fog::Vsphere::Compute::Rule
        attribute :datacenter
        attribute :cluster

        def all(_filters = {})
          requires :datacenter, :cluster
          load service.list_rules(datacenter: datacenter, cluster: cluster)
        end

        def get(key_or_name)
          all.find { |rule| [rule.key, rule.name].include? key_or_name } ||
            raise(Fog::Vsphere::Compute::NotFound, "no such rule #{key_or_name}")
        end

        # Pass datacenter/cluster to every new rule
        def new(attributes = {})
          requires :datacenter, :cluster
          super(attributes.merge(datacenter: datacenter, cluster: cluster))
        end
      end
    end
  end
end
