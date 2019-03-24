module Fog
  module Vsphere
    class Compute
      class Real
        def get_datastore(name, datacenter_name)
          datastore = list_datastores(datacenter: datacenter_name).detect { |ds| ds[:name] == name }
          raise(Fog::Vsphere::Compute::NotFound) unless datastore
          datastore
        end

        protected

        def get_raw_datastore(name, datacenter_name)
          shared_request.get_raw_datastore(name, datacenter_name)
        end
      end

      class Mock
        def get_datastore(name, datacenter_name); end
      end
    end
  end
end
