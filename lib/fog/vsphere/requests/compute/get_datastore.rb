module Fog
  module Compute
    class Vsphere
      class Real
        def get_datastore(name, datacenter_name)
          datastore = get_raw_datastore(name, datacenter_name)
          raise(Fog::Compute::Vsphere::NotFound) unless datastore
          datastore_attributes(datastore, datacenter_name)
        end

        protected

        def get_raw_datastore(name, datacenter_name)
          get_raw_datastores(datacenter_name).detect { |ds| ds.name == name }
        end

        def get_raw_datastores(datacenter_name)
          list_container_view(datacenter_name, 'Datastore', :datastoreFolder)
        end
      end

      class Mock
        def get_datastore(name, datacenter_name); end
      end
    end
  end
end
