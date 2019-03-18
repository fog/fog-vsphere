module Fog
  module Vsphere
    class Compute
      class Real
        def list_compute_resources(filters = {})
          datacenter_name = filters[:datacenter]
          # default to show all compute_resources
          only_active = filters[:effective] || false
          compute_resources = raw_compute_resources datacenter_name

          compute_resources.map do |compute_resource|
            next if compute_resource.instance_of? RbVmomi::VIM::Folder
            summary = compute_resource.summary
            next if only_active && (summary.numEffectiveHosts == 0)
            compute_resource_attributes(compute_resource, datacenter_name)
          end.compact
        end

        def raw_compute_resources(datacenter_name)
          find_raw_datacenter(datacenter_name).find_compute_resource('').children
        end

        protected

        def compute_resource_attributes(compute_resource, _datacenter)
          overall_usage = compute_resource.host.inject(overallCpuUsage: 0, overallMemoryUsage: 0) do |sum, host|
            {
              overallCpuUsage: sum[:overallCpuUsage] + (host.summary.quickStats.overallCpuUsage || 0),
              overallMemoryUsage: sum[:overallMemoryUsage] + (host.summary.quickStats.overallMemoryUsage || 0)
            }
          end
          {
            id: managed_obj_id(compute_resource),
            name: compute_resource.name,
            totalCpu: compute_resource.summary.totalCpu,
            totalMemory: compute_resource.summary.totalMemory,
            numCpuCores: compute_resource.summary.numCpuCores,
            numCpuThreads: compute_resource.summary.numCpuThreads,
            effectiveCpu: compute_resource.summary.effectiveCpu,
            effectiveMemory: compute_resource.summary.effectiveMemory,
            numHosts: compute_resource.summary.numHosts,
            numEffectiveHosts: compute_resource.summary.numEffectiveHosts,
            overallStatus: compute_resource.summary.overallStatus,
            overallCpuUsage: overall_usage[:overallCpuUsage],
            overallMemoryUsage: overall_usage[:overallMemoryUsage],
            effective: compute_resource.summary.numEffectiveHosts > 0,
            isSingleHost: compute_resource.summary.numHosts == 1
          }
        end
      end
      class Mock
        def list_compute_resources(_filters = {})
          [
            {
              id: 'domain-s7',
              name: 'fake-host',
              totalCpu: 33_504,
              totalMemory: 154_604_142_592,
              numCpuCores: 12,
              numCpuThreads: 24,
              effectiveCpu: 32_247,
              effectiveMemory: 135_733,
              numHosts: 1,
              numEffectiveHosts: 1,
              overallStatus: 'gray',
              overallCpuUsage: 15_682,
              overallMemoryUsage: 132_755,
              effective: true,
              isSingleHost: true
            }, {
              id: 'domain-s74',
              name: 'fake-cluster',
              totalCpu: 41_484,
              totalMemory: 51_525_996_544,
              numCpuCores: 12,
              numCpuThreads: 24,
              effectiveCpu: 37_796,
              effectiveMemory: 45_115,
              numHosts: 2,
              numEffectiveHosts: 2,
              overallStatus: 'gray',
              overallCpuUsage: 584,
              overallMemoryUsage: 26_422,
              effective: true,
              isSingleHost: false
            }
          ]
        end
      end
    end
  end
end
