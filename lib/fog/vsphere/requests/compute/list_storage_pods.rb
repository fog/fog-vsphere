module Fog
  module Compute
    class Vsphere
      class Real
        def list_storage_pods(filters = {})
          datacenter_name = filters[:datacenter]
          raw_storage_pods(datacenter_name).map do |storage_pod|
            storage_pod_attributes(storage_pod, datacenter_name)
          end.compact
        end

        private

        def raw_storage_pods(datacenter_name)
          list_container_view(datacenter_name, 'StoragePod')
        end

        protected

        def storage_pod_attributes(storage_pod, datacenter)
          {
            id: managed_obj_id(storage_pod),
            name: storage_pod.name,
            freespace: storage_pod.summary.freeSpace,
            capacity: storage_pod.summary.capacity,
            datacenter: datacenter
          }
        end
      end
      class Mock
        def list_storage_pods(filters = {})
          if filters.key?(:datacenter)
            data[:storage_pods].select { |h| h[:datacenter] == filters[:datacenter] }
          else
            data[:storage_pods]
          end
        end
      end
    end
  end
end
