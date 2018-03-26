module Fog
  module Compute
    class Vsphere
      class Real
        def list_networks(filters = { })
          datacenter_name = filters[:datacenter]
          cluster_name = filters.fetch(:cluster, nil)
          # default to show all networks
          only_active = filters[:accessible] || false
          raw_networks(datacenter_name, cluster_name).map do |network|
            next if only_active && !network.summary.accessible
            network_attributes(network, datacenter_name)
          end.compact
        end

        def raw_networks(datacenter_name, cluster = nil)
          if cluster.nil?
            find_raw_datacenter(datacenter_name).network
          else
            get_raw_cluster(cluster, datacenter_name).network
          end
        end

        protected

        def network_attributes(network, datacenter)
          if network.kind_of?(RbVmomi::VIM::DistributedVirtualPortgroup)
            id = network.key
            virtualswitch = network.config.distributedVirtualSwitch.name
            vlanid = raw_network_vlan_id(network.config.defaultPortConfig.vlan)
          else
            id = managed_obj_id(network)
            virtualswitch = nil
            vlanid = nil
          end
          {
            :id            => id,
            :name          => network.name,
            :accessible    => network.summary.accessible,
            :datacenter    => datacenter,
            :virtualswitch => virtualswitch,
            :vlanid        => vlanid
          }
        end

        private

        def raw_network_vlan_id(vlan)
          case vlan
          when RbVmomi::VIM::VmwareDistributedVirtualSwitchVlanIdSpec
            vlan.vlanId
          else
            nil
          end
        end
      end
      class Mock
        def list_networks(filters)
          datacenter_name = filters[:datacenter]
          cluster_name = filters.fetch(:cluster, nil)
          if cluster_name.nil?
            self.data[:networks].values.select { |d| d['datacenter'] == datacenter_name } or
              raise Fog::Compute::Vsphere::NotFound
          else
            self.data[:networks].values.select { |d| d['datacenter'] == datacenter_name && d['cluster'].include?(cluster_name) } or
              raise Fog::Compute::Vsphere::NotFound
          end
        end
      end
    end
  end
end
