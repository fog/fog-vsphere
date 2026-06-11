module Fog
  module Vsphere
    class Compute
      class SCSIController < Fog::Model
        attribute :shared_bus
        attribute :type
        attribute :unit_number
        attribute :key, type: :integer
        attribute :server_id

        DEFAULT_KEY = 1000
        DEFAULT_TYPE = "ParaVirtualSCSIController".freeze

        def initialize(attributes = {})
          super
          self.key ||= DEFAULT_KEY
          self.type ||= DEFAULT_TYPE
        end

        def to_s
          "#{type} ##{key}: shared: #{shared_bus}, unit_number: #{unit_number}"
        end
      end
    end
  end
end
