module Fog
  module Vsphere
    class Compute
      class Real
        def get_compute_resource(name, datacenter_name)
          compute_resource = get_raw_compute_resource(name, datacenter_name)
          raise(Fog::Vsphere::Compute::NotFound) unless compute_resource
          compute_resource_attributes(compute_resource, datacenter_name)
        end

        protected

        def get_raw_compute_resource(name, datacenter_name)
          find_raw_datacenter(datacenter_name).find_compute_resource(name)
        end
      end

      class Mock
        def get_compute_resource(_name, _datacenter_name)
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
          }
        end
      end
    end
  end
end
