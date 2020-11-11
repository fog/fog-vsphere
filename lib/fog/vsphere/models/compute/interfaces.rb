module Fog
  module Vsphere
    class Compute
      class Interfaces < Fog::Collection
        model Fog::Vsphere::Compute::Interface

        attribute :server_id

        def all(_filters = {})
          requires :server_id

          case server
          when Fog::Vsphere::Compute::Server
            load service.list_vm_interfaces(server.id)
          when Fog::Vsphere::Compute::Template
            load service.list_template_interfaces(server.id)
          else
            raise 'interfaces should have vm or template'
          end

          each { |interface| interface.server_id = server.id }
          self
        end

        def get(id)
          requires :server_id

          case server
          when Fog::Vsphere::Compute::Server
            interface = service.get_vm_interface(server.id, key: id, mac: id, name: id, datacenter: server.datacenter)
          when Fog::Vsphere::Compute::Template
            interface = service.get_template_interfaces(server.id, key: id, mac: id, name: id)
          else

            raise 'interfaces should have vm or template'
          end

          if interface
            Fog::Vsphere::Compute::Interface.new(interface.merge(server_id: server.id, service: service))
          end
        end

        def new(attributes = {})
          if server_id
            super({ server_id: server_id }.merge(attributes))
          else
            super
          end
        end

        def server
          return nil if server_id.nil?
          service.servers.get(server_id)
        end

        def server=(new_server)
          server_id = new_server.id
        end
      end
    end
  end
end
