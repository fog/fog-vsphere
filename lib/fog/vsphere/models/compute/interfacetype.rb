module Fog
  module Vsphere
    class Compute
      class Interfacetype < Fog::Model
        identity :id

        #        attribute :class
        attribute :name
        attribute :datacenter
        attribute :servertype

        def initialize(attributes = {})
          super attributes
        end

        def to_s
          name
        end
      end
    end
  end
end
