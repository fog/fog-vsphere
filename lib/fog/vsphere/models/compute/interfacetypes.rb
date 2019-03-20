module Fog
  module Vsphere
    class Compute
      class Interfacetypes < Fog::Collection
        autoload :Interfacetype, File.expand_path('../interfacetype', __FILE__)

        model Fog::Vsphere::Compute::Interfacetype
        attr_accessor :datacenter
        attr_accessor :servertype

        def all(filters = {})
          requires :servertype
          case servertype
          when Fog::Vsphere::Compute::Servertype
            load service.list_interface_types(filters.merge(datacenter: datacenter,
                                                            servertype: servertype.id))
          else
            raise 'interfacetypes should have a servertype'
          end
        end

        def get(id)
          requires :servertype
          requires :datacenter
          new service.get_interface_type id, servertype, datacenter
        rescue Fog::Vsphere::Compute::NotFound
          nil
        end
      end
    end
  end
end
