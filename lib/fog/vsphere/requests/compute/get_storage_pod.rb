module Fog
  module Compute
    class Vsphere
      class Real
        def get_storage_pod(name, datacenter_name)
          storage_pod = get_raw_storage_pod(name, datacenter_name)
          raise(Fog::Compute::Vsphere::NotFound) unless storage_pod
          storage_pod_attributes(storage_pod, datacenter_name)
        end

        protected

        def get_raw_storage_pod(name, datacenter_name)
          raw_storage_pods(datacenter_name).detect { |pod| pod.name == name }
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
