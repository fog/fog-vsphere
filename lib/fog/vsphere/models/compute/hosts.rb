module Fog
  module Vsphere
    class Compute
      class Hosts < Fog::Collection
        attribute :datacenter
        attribute :cluster

        model Fog::Vsphere::Compute::Host

        def all(_filters = {})
          requires :datacenter, :cluster
          load service.list_hosts(datacenter: datacenter, cluster: cluster)
        end

        def get(name)
          all.find { |host| host.name == name } ||
            raise(Fog::Vsphere::Compute::NotFound, "no such host #{name}")
        end
      end
    end
  end
end
