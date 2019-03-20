module Fog
  module Vsphere
    class Compute
      class Template < Fog::Model
        identity :id
        attribute :name
        attribute :uuid
      end
    end
  end
end
