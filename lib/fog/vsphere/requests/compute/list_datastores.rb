module Fog
  module Vsphere
    class Compute
      class Real
        def list_datastores(filters = {})
          datacenter_name = filters[:datacenter]
          cluster_name = filters.fetch(:cluster, nil)
          # default to show all datastores
          only_active = filters[:accessible] || false

          dc = find_raw_datacenter(datacenter_name)

          datastores = if cluster_name
                         cluster = get_raw_cluster(cluster_name, dc)
                         property_collector_results(datastore_cluster_filter_spec(cluster))
                       else
                         property_collector_results(datastore_filter_spec(dc))
                       end

          datastores.map do |datastore|
            next if only_active && !datastore['summary.accessible']
            map_attrs_to_hash(datastore, datastore_attribute_mapping).merge(
              datacenter: datacenter_name,
              id: managed_obj_id(datastore.obj)
            )
          end.compact
        end

        protected

        def datastore_filter_spec(obj)
          RbVmomi::VIM.PropertyFilterSpec(
            objectSet: [
              obj: obj.datastoreFolder,
              skip: true,
              selectSet: [
                folder_traversal_spec
              ]
            ],
            propSet: datastore_filter_prop_set
          )
        end

        def datastore_cluster_filter_spec(obj)
          RbVmomi::VIM.PropertyFilterSpec(
            objectSet: [
              obj: obj,
              skip: true,
              selectSet: [
                compute_resource_datastore_traversal_spec
              ]
            ],
            propSet: datastore_filter_prop_set
          )
        end

        def datastore_filter_prop_set
          [
            { type: 'Datastore', pathSet: datastore_attribute_mapping.values }
          ]
        end

        def compute_resource_datastore_traversal_spec
          RbVmomi::VIM.TraversalSpec(
            name: 'computeResourceDatastoreTraversalSpec',
            type: 'ComputeResource',
            path: 'datastore',
            skip: false
          )
        end

        def datastore_attribute_mapping
          {
            name: 'summary.name',
            accessible: 'summary.accessible',
            type: 'summary.type',
            freespace: 'summary.freeSpace',
            capacity: 'summary.capacity',
            uncommitted: 'summary.uncommitted'
          }
        end
      end
      class Mock
        def list_datastores(filters)
          datacenter_name = filters[:datacenter]
          cluster_name = filters.fetch(:cluster, nil)
          if cluster_name.nil?
            data[:datastores].values.select { |d| d['datacenter'] == datacenter_name } ||
              raise(Fog::Vsphere::Compute::NotFound)
          else
            data[:datastores].values.select { |d| d['datacenter'] == datacenter_name && d['cluster'].include?(cluster_name) } ||
              raise(Fog::Vsphere::Compute::NotFound)
          end
        end
      end
    end
  end
end
