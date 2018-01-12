module Fog
  module Compute
    class Vsphere
      class Real
        def get_network(name, datacenter_name)
          network = get_raw_network(name, datacenter_name)
          raise(Fog::Compute::Vsphere::NotFound) unless network
          network_attributes(network, datacenter_name)
        end

        protected

        def get_raw_network(name, datacenter_name, distributedswitch=nil)
          finder = choose_finder(name, distributedswitch)
          get_all_raw_networks(datacenter_name).find { |n| finder.call(n) }
        end
      end

      module Shared

        protected

        def get_all_raw_networks(datacenter_name)
          list_container_view(datacenter_name, 'Network', :networkFolder)
        end

        def choose_finder(name, distributedswitch)
          case distributedswitch
          when String
            # only the one will do
            Proc.new { |n| (n.name == name) &&
                (n.class.to_s == "DistributedVirtualPortgroup") &&
                (n.config.distributedVirtualSwitch.name == distributedswitch)
            }
          when :dvs
            # the first distributed virtual switch will do - selected by network - gives control to vsphere
            Proc.new { |n| (n.name == name) && (n.class.to_s == "DistributedVirtualPortgroup") }
          else
            # the first matching network will do, seems like the non-distributed networks come first
            Proc.new { |n| (n.name == name) }
          end
        end

      end

      class Mock
        def get_network(id)
        end
      end
    end
  end
end
