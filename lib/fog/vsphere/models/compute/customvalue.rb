module Fog
  module Vsphere
    class Compute
      class Customvalue < Fog::Model
        attribute :value
        attribute :key

        def to_s
          value
        end
      end
    end
  end
end
