module Fog
  module Vsphere
    class Compute
      class StoragePod < Fog::Model
        identity :id

        attribute :name
        attribute :datacenter
        attribute :type
        attribute :freespace
        attribute :capacity

        def to_s
          name
        end
      end
    end
  end
end
