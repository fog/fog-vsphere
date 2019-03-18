module Fog
  module Vsphere
    class Compute
      class Real
        def list_storage_pods(filters = {})
          datacenter_name = filters[:datacenter]

          dc = find_raw_datacenter(datacenter_name)

          storage_pods = property_collector_results(storage_pod_filter_spec(dc))

          storage_pods.map do |storage_pod|
            map_attrs_to_hash(storage_pod, storage_pod_attribute_mapping).merge(
              datacenter: datacenter_name,
              id: managed_obj_id(storage_pod.obj)
            )
          end
        end

        protected

        def storage_pod_filter_spec(obj)
          RbVmomi::VIM.PropertyFilterSpec(
            objectSet: [
              obj: obj.datastoreFolder,
              skip: true,
              selectSet: [
                folder_traversal_spec
              ]
            ],
            propSet: storage_pod_filter_prop_set
          )
        end

        def storage_pod_filter_prop_set
          [
            { type: 'StoragePod', pathSet: storage_pod_attribute_mapping.values }
          ]
        end

        def storage_pod_attribute_mapping
          {
            name: 'name',
            freespace: 'summary.freeSpace',
            capacity: 'summary.capacity'
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
