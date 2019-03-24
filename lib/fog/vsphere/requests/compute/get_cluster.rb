module Fog
  module Vsphere
    class Compute
      class Real
        def get_cluster(name, datacenter_name)
          cluster = get_raw_cluster(name, datacenter_name)
          raise(Fog::Vsphere::Compute::NotFound) unless cluster
          cluster_attributes(cluster, datacenter_name)
        end

        protected

        def get_raw_cluster(name, datacenter_name_or_obj)
          shared_request.get_raw_cluster(name, datacenter_name_or_obj)
        end
      end

      class Mock
        def get_cluster(name, datacenter_name)
          data[:clusters].find { |c| c[:name] == name && c[:datacenter] == datacenter_name } ||
            raise(Fog::Vsphere::Compute::NotFound)
        end
        alias get_raw_cluster get_cluster
      end
    end
  end
end
