module Fog
  module Vsphere
    class Compute
      class Real
        def get_datacenter(name)
          dc = find_raw_datacenter(name)
          raise(Fog::Vsphere::Compute::NotFound) unless dc
          { name: dc.name, status: dc.overallStatus, path: raw_getpathmo(dc) }
        end

        protected

        def find_raw_datacenter(name)
          raw_datacenters.find { |d| d.name == name } || get_raw_datacenter(name)
        end

        # @note RbVmomi takes path instead of name as argument to find datacenter
        def get_raw_datacenter(path)
          connection.serviceInstance.find_datacenter(path)
        end
      end

      class Mock
        def get_datacenter(name)
          dc = data[:datacenters][name]
          raise(Fog::Vsphere::Compute::NotFound) unless dc
          dc
        end
      end
    end
  end
end
