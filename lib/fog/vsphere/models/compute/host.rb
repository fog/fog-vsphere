module Fog
  module Compute
    class Vsphere
      class Host < Fog::Model
        identity :name

        attribute :datacenter
        attribute :cluster
        attribute :name
        attribute :vm_ids

        def to_s
          name
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
