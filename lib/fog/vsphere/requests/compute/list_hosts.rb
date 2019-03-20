# rubocop:disable Lint/RescueWithoutErrorClass
module Fog
  module Vsphere
    class Compute
      class Real
        def list_hosts(filters = {})
          cluster = get_raw_cluster(filters[:cluster], filters[:datacenter])

          results = property_collector_results(host_system_filter_spec(cluster))

          results.map do |host|
            hsh = map_attrs_to_hash(host, host_system_attribute_mapping)
            hsh.merge(
              datacenter: filters[:datacenter],
              cluster: filters[:cluster],
              ipaddress: (begin
                            host['config.network.vnic'].first.spec.ip.ipAddress
                          rescue
                            nil
                          end),
              ipaddress6: (begin
                             host['config.network.vnic'].first.spec.ip.ipV6Config.ipV6Address.first.ipAddress
                           rescue
                             nil
                           end),
              vm_ids: proc {
                host['vm'].map do |vm|
                  begin
                                           vm.config.instanceUuid
                                         rescue
                                           nil
                                         end
                end
              }
            )
          end
        end

        protected

        def map_attrs_to_hash(obj, attribute_mapping)
          attribute_mapping.each_with_object({}) do |(k, v), hsh|
            hsh[k] = obj[v]
          end
        end

        def property_collector_results(filter_spec)
          property_collector = connection.serviceContent.propertyCollector
          property_collector.RetrieveProperties(specSet: [filter_spec])
        end

        def compute_resource_host_traversal_spec
          RbVmomi::VIM.TraversalSpec(
            name: 'computeResourceHostTraversalSpec',
            type: 'ComputeResource',
            path: 'host',
            skip: false
          )
        end

        def host_system_filter_spec(obj)
          RbVmomi::VIM.PropertyFilterSpec(
            objectSet: [
              obj: obj,
              selectSet: [
                compute_resource_host_traversal_spec
              ]
            ],
            propSet: [
              { type: 'HostSystem', pathSet: host_system_attribute_mapping.values + ['config.network.vnic', 'vm'] }
            ]
          )
        end

        def host_system_attribute_mapping
          {
            name:            'name',
            cpu_cores:       'hardware.cpuInfo.numCpuCores',
            cpu_sockets:     'hardware.cpuInfo.numCpuPackages',
            cpu_threads:     'hardware.cpuInfo.numCpuThreads',
            cpu_hz:          'hardware.cpuInfo.hz',
            memory:          'hardware.memorySize',
            uuid:            'hardware.systemInfo.uuid',
            model:           'hardware.systemInfo.model',
            vendor:          'hardware.systemInfo.vendor',
            product_name:    'summary.config.product.name',
            product_version: 'summary.config.product.version',
            hostname:        'config.network.dnsConfig.hostName',
            domainname:      'config.network.dnsConfig.domainName'
          }
        end
      end

      class Mock
        def list_hosts(filters = {})
          data[:hosts].values.select { |r| r[:datacenter] == filters[:datacenter] && r[:cluster] == filters[:cluster] }
        end
      end
    end
  end
end
