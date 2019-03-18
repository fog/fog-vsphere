module Fog
  module Compute
    class Vsphere
      class Rules < Fog::Collection
        autoload :Rule, File.expand_path('../rule', __FILE__)

        model Fog::Compute::Vsphere::Rule
        attribute :datacenter
        attribute :cluster

        def all(_filters = {})
          requires :datacenter, :cluster
          load service.list_rules(datacenter: datacenter, cluster: cluster)
        end

        def get(key_or_name)
          all.find { |rule| [rule.key, rule.name].include? key_or_name } ||
            raise(Fog::Compute::Vsphere::NotFound, "no such rule #{key_or_name}")
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
