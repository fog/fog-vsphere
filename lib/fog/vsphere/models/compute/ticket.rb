require 'fog/compute/models/server'

module Fog
  module Compute
    class Vsphere
      class Ticket < Fog::Model
        attribute :server_id

        attribute :ticket
        attribute :host
        attribute :port
        attribute :ssl_thumbprint
      end
    end
  end
end
