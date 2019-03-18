module Fog
  module Vsphere
    class Compute
      class Volumes < Fog::Collection
        autoload :Volume, File.expand_path('../volume', __FILE__)

        attribute :server_id

        model Fog::Vsphere::Compute::Volume

        def all(_filters = {})
          requires :server_id

          case server
          when Fog::Vsphere::Compute::Server
            load service.list_vm_volumes(server.id)
          when Fog::Vsphere::Compute::Template
            load service.list_template_volumes(server.id)
          else
            raise 'volumes should have vm or template'
            end

          each { |volume| volume.server = server }
          self
        end

        def get(id)
          new service.get_volume(id)
        end

        def new(attributes = {})
          if server_id
            # Default to the root volume datastore if one is not configured.
            datastore = !attributes.key?(:datastore) && any? ? first.datastore : nil

            super({ server_id: server_id, datastore: datastore }.merge!(attributes))
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
