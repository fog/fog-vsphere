module Fog
  module Vsphere
    class Compute
      class NVMEController < Fog::Model
        attribute :type
        attribute :unit_number
        attribute :key, type: :integer
        attribute :server_id
        DEFAULT_KEY = 2000
        DEFAULT_TYPE = "VirtualNVMEController".freeze

        def initialize(attributes = {})
          super
          self.key ||= DEFAULT_KEY
          self.type ||= DEFAULT_TYPE
        end

        def to_s
          "#{type} ##{key}:, unit_number: #{unit_number}"
        end
      end
    end
  end
end
