module Fog
  module Compute
    class Vsphere
      class Real
        def add_vm_interface(vmid, options = {})
          raise ArgumentError, 'instance id is a required parameter' unless vmid

          interface = get_interface_from_options(vmid, options.merge(server_id: vmid))
          vm_reconfig_hardware('instance_uuid' => vmid, 'hardware_spec' => { 'deviceChange' => [create_interface(interface, 0, :add, options)] })
        end

        def destroy_vm_interface(vmid, options = {})
          raise ArgumentError, 'instance id is a required parameter' unless vmid

          interface = get_interface_from_options(vmid, options.merge(server_id: vmid))
          vm_reconfig_hardware('instance_uuid' => vmid, 'hardware_spec' => { 'deviceChange' => [create_interface(interface, interface.key, :remove)] })
        end

        def update_vm_interface(vmid, options = {})
          raise ArgumentError, 'instance id is a required parameter' unless vmid
          raise ArgumentError, "'datacenter' is a required key in options: #{options}" unless options.key?(:datacenter)

          datacenter_name = options[:datacenter]

          interface = get_interface_from_options(vmid, options)
          raw_interface = get_raw_interface(vmid, key: interface.key, datacenter: datacenter_name)

          if options[:network]
            interface.network = options[:network]
            backing = create_nic_backing(interface, datacenter: datacenter_name)
            raw_interface.backing = backing
          end

          apply_options_to_raw_interface(raw_interface, options)

          spec = {
            operation: :edit,
            device: raw_interface
          }

          vm_reconfig_hardware('instance_uuid' => vmid, 'hardware_spec' => { 'deviceChange' => [spec] })
        end

        private

        def get_interface_from_options(vmid, options)
          if options && options[:interface]
            options[:interface]

          elsif options[:key] && (options[:key] > 0)
            oldattributes = get_vm_interface(vmid, options)
            Fog::Compute::Vsphere::Interface.new(oldattributes.merge(options))

          elsif options[:type] && options[:network]
            Fog::Compute::Vsphere::Interface.new options

          else
            raise ArgumentError, 'interface is a required parameter or pass options with type and network'
          end
        end

        def apply_options_to_raw_interface(raw_interface, options)
          if options[:connectable]
            options[:connectable].each do |key, value|
              raw_interface.connectable.send("#{key}=", value)
            end
          end
          raw_interface
        end
      end

      class Mock
        def add_vm_interface(vmid, options = {})
          raise ArgumentError, 'instance id is a required parameter' unless vmid
          raise ArgumentError, 'interface is a required parameter' unless options && options[:interface]
          true
        end

        def destroy_vm_interface(vmid, options = {})
          raise ArgumentError, 'instance id is a required parameter' unless vmid
          raise ArgumentError, 'interface is a required parameter' unless options && options[:interface]
          true
        end

        def update_vm_interface(_vmid, options = {})
          return unless options[:interface]
          options[:interface].network = options[:network]
          options[:interface].type    = options[:type]
        end
      end
    end
  end
end
