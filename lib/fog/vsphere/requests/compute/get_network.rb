module Fog
  module Vsphere
    class Compute
      class Real
        def get_network(ref_or_name, datacenter_name)
          network = get_raw_network(ref_or_name, datacenter_name)
          raise(Fog::Vsphere::Compute::NotFound) unless network
          network_attributes(network, datacenter_name)
        end

        protected

        def get_raw_network(ref_or_name, datacenter_name, distributedswitch = nil)
          shared_request.get_raw_network(ref_or_name, datacenter_name, distributedswitch)
        end
      end

      class Mock
        def get_network(id); end
      end
    end
  end
end
