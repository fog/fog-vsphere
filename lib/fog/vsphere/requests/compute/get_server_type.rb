module Fog
  module Vsphere
    class Compute
      class Real
        def get_server_type(id, datacenter, _filter = {})
          server_type = get_raw_server_type(id, datacenter)
          raise(Fog::Vsphere::Compute::NotFound) unless server_type
          server_type_attributes(server_type, datacenter)
        end

        protected

        def get_raw_server_type(id, datacenter, _filter = {})
          types = raw_server_types(datacenter)
          raise(Fog::Vsphere::Compute::NotFound) unless types
          types = types.select { |servertype| servertype.id == id }.first
          raise(Fog::Vsphere::Compute::NotFound) unless types
          types
        end
      end
      class Mock
        def get_server_type(_id)
          { id: 'rhel6Guest',
            name: 'rhel6Guest',
            family: 'linuxGuest',
            fullname: 'Red Hat Enterprise Linux 6 (32-Bit)',
            datacenter: 'Solutions' }
        end
      end
    end
  end
end
