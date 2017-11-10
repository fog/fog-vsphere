module Fog
  module Compute
    class Vsphere
      class Host < Fog::Model
        identity :name

        attribute :datacenter
        attribute :cluster
        attribute :name
        attribute :vm_ids
        attribute :cpu_cores
        attribute :cpu_sockets
        attribute :cpu_threads
        attribute :memory
        attribute :uuid

        # Lazy Loaded Attributes
        [:vm_ids].each do |attr|
          define_method attr do
            attributes[attr] = attributes[attr].call if attributes[attr].is_a?(Proc)
            attributes[attr]
          end
        end
        # End Lazy Loaded Attributes

        def to_s
          name
        end

        def memory_mb
          memory / 1024 / 1024
        end

        def shutdown
          service.host_shutdown(name, cluster, datacenter)
        end

        def start_maintenance
          service.host_start_maintenance(name, cluster, datacenter)
        end

        def finish_maintenance
          service.host_finish_maintenance(name, cluster, datacenter)
        end
      end
    end
  end
end
