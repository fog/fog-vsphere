module Fog
  module Vsphere
    class Compute
      class Real
        # => VirtualE1000(
        # addressType: "assigned",
        # backing: VirtualEthernetCardNetworkBackingInfo(
        #  deviceName: "VM Network",
        #  dynamicProperty: [],
        #  network: Network("network-163"),
        #  useAutoDetect: false
        # ),
        # connectable: VirtualDeviceConnectInfo(
        #  allowGuestControl: true,
        #  connected: true,
        #  dynamicProperty: [],
        #  startConnected: true,
        #  status: "ok"
        # ),
        # controllerKey: 100,
        # deviceInfo: Description(
        #  dynamicProperty: [],
        #  label: "Network adapter 1",
        #  summary: "VM Network"
        # ),
        # dynamicProperty: [],
        # key: 4000,
        # macAddress: "00:50:56:a9:00:28",
        # unitNumber: 7,
        #
        def list_vm_interfaces(vm_id, datacenter = nil)
          get_raw_interfaces(vm_id, datacenter).map { |nic| raw_to_hash(nic, datacenter) }
        end

        def get_vm_interface(vm_id, options = {})
          raw = get_raw_interface(vm_id, options)
          raw_to_hash(raw, options[:datacenter]) if raw
        end

        def get_raw_interfaces(vm_id, datacenter = nil)
          get_vm_ref(vm_id, datacenter).config.hardware.device.grep(RbVmomi::VIM::VirtualEthernetCard)
        end

        def get_raw_interface(vm_id, options = {})
          raise ArgumentError, 'instance id is a required parameter' unless vm_id

          if options.is_a? Fog::Vsphere::Compute::Interface
            options

          else
            raise ArgumentError, "Either key or name is a required parameter. options: #{options}" unless options.key?(:key) || options.key?(:mac) || options.key?(:name)
            raise ArgumentError, "'datacenter' is a required parameter in options: #{options}" unless options.key?(:datacenter)

            get_raw_interfaces(vm_id, options[:datacenter]).find do |nic|
              (options.key?(:key) && (nic.key == options[:key].to_i)) ||
                (options.key?(:mac) && (nic.macAddress == options[:mac])) ||
                (options.key?(:name) && (nic.deviceInfo.label == options[:name]))
            end
          end
        end

        private

        def raw_to_hash(nic, datacenter)
          if nic.backing.respond_to?(:network)
            network = nic.backing.network.name
          elsif nic.backing.respond_to?(:port)
            network = nic.backing.port.portgroupKey
          elsif nic.backing.respond_to?(:opaqueNetworkId)
            opaquenetworks = list_networks(:datacenter => datacenter).select { |net| net.key?(:opaqueNetworkId) }
            network = opaquenetworks.find do |opaquenetwork|
                        nic.backing.opaqueNetworkId == opaquenetwork[:opaqueNetworkId]
                      end[:id]
          else
            network = nil
          end
          {
            name: nic.deviceInfo.label,
            mac: nic.macAddress,
            network: network,
            status: nic.connectable.status,
            connected: nic.connectable.connected,
            summary: nic.deviceInfo.summary,
            type: nic.class,
            key: nic.key
          }
        end
        # rubocop:enable Style/ConditionalAssignment
      end

      class Mock
        def list_vm_interfaces(vm_id); end
      end
    end
  end
end
