module Fog
  module Vsphere
    class Compute
      class Real
        def get_network(ref_or_name, datacenter_name)
          network = get_raw_network(ref_or_name, datacenter_name)
          raise(Fog::Vsphere::Compute::NotFound) unless network
          network_attributes(network, datacenter_name)
        end

        protected

        def get_raw_network(ref_or_name, datacenter_name, distributedswitch = nil)
          finder = choose_finder(ref_or_name, distributedswitch)
          get_all_raw_networks(datacenter_name).find { |n| finder.call(n) }
        end

        def network_attributes(network, datacenter_name)
          {
            id: managed_obj_id(network),
            name: network.name,
            datacenter: datacenter_name,
            vlanid: nil
          }
        end
      end

      module Shared
        protected

        def get_all_raw_networks(datacenter_name)
          list_container_view(datacenter_name, 'Network', :networkFolder)
        end

        def choose_finder(ref_or_name, distributedswitch)
          case distributedswitch
          when String
            # only the one will do
            proc do |n|
              n._ref == ref_or_name || (
                n.is_a?(RbVmomi::VIM::DistributedVirtualPortgroup) && (n.name == ref_or_name || n.key == ref_or_name) &&
                (n.config.distributedVirtualSwitch.name == distributedswitch)
              )
            end
          when :dvs
            # the first distributed virtual switch will do - selected by network - gives control to vsphere
            proc do |n|
              n._ref == ref_or_name || (
                n.is_a?(RbVmomi::VIM::DistributedVirtualPortgroup) && (n.name == ref_or_name || n.key == ref_or_name)
              )
            end
          else
            # the first matching network will do, seems like the non-distributed networks come first
            proc { |n| n._ref == ref_or_name || n.name == ref_or_name || (n.is_a?(RbVmomi::VIM::DistributedVirtualPortgroup) && n.key == ref_or_name) }
          end
        end
      end

      class Mock
        def get_network(id); end
      end
    end
  end
end
