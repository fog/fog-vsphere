module Fog
  module Vsphere
    class Compute
      class Tickets < Fog::Collection
        autoload :Ticket, File.expand_path('../ticket', __FILE__)

        model Fog::Vsphere::Compute::Ticket

        attr_accessor :server

        def create(opts = {})
          requires :server
          raise 'server must be a Fog::Vsphere::Compute::Server' unless server.is_a?(Fog::Vsphere::Compute::Server)
          new(
            service.vm_acquire_ticket(
              opts.merge(
                'instance_uuid' => server.instance_uuid
              )
            )
          )
        end
     end
    end
  end
end
