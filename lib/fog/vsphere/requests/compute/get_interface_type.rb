module Fog
  module Compute
    class Vsphere
      class Real
        def get_interface_type(id, servertype, datacenter, _filter = {})
          interfacetype = list_interface_types(filters = { id: id,
                                                           datacenter: datacenter,
                                                           servertype: servertype.id }).first
          raise(Fog::Compute::Vsphere::NotFound) unless interfacetype
          interfacetype
        end
      end
    end
  end
end
