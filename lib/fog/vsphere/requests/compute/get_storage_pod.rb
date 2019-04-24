module Fog
  module Vsphere
    class Compute
      class Real
        def get_storage_pod(name, datacenter_name)
          storage_pod = list_storage_pods(datacenter: datacenter_name).detect { |pod| pod[:name] == name }
          raise(Fog::Vsphere::Compute::NotFound) unless storage_pod
          storage_pod
        end

        protected

        def get_raw_storage_pod(name, datacenter_name)
          shared_request.get_raw_storage_pod(name, datacenter_name)
        end
      end

      class Mock
        def get_storage_pod(name, datacenter_name)
          list_storage_pods(datacenter: datacenter_name).detect { |h| h[:name] == name }
        end
      end
    end
  end
end
