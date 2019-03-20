module Fog
  module Vsphere
    class Compute
      class Network < Fog::Model
        identity :id

        attribute :name
        attribute :datacenter
        attribute :accessible # reachable by at least one hypervisor
        attribute :virtualswitch
        attribute :vlanid

        def to_s
          name
        end
      end
    end
  end
end
