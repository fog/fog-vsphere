module Fog
  module Vsphere
    class Compute
      class Servertypes < Fog::Collection
        autoload :Servertype, File.expand_path('../servertype', __FILE__)

        model Fog::Vsphere::Compute::Servertype
        attr_accessor :datacenter, :id, :fullname

        def all(filters = {})
          load service.list_server_types(filters.merge(datacenter: datacenter))
        end

        def get(id)
          requires :datacenter
          new service.get_server_type(id, datacenter)
        rescue Fog::Vsphere::Compute::NotFound
          nil
        end
      end
    end
  end
end
