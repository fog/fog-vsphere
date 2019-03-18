module Fog
  module Compute
    class Vsphere
      class Tickets < Fog::Collection
        autoload :Ticket, File.expand_path('../ticket', __FILE__)

        model Fog::Compute::Vsphere::Ticket

        attr_accessor :server

        def create(opts = {})
          requires :server
          raise 'server must be a Fog::Compute::Vsphere::Server' unless server.is_a?(Fog::Compute::Vsphere::Server)
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
