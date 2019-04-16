module Fog
  module Vsphere
    class Compute
      class Real
        def update_vm(server)
          attributes = server.attributes
          datacenter = attributes[:datacenter]
          vm_mob_ref = get_vm_ref(attributes[:instance_uuid], datacenter)

          device_change = []
          spec = {}

          # Name
          spec[:name] = attributes[:name]

          # CPUs
          spec[:numCPUs] = attributes[:cpus]
          spec[:numCoresPerSocket] = attributes[:corespersocket]

          # Memory
          spec[:memoryMB] = attributes[:memory_mb]

          # HotAdd
          spec[:cpuHotAddEnabled] = attributes[:cpuHotAddEnabled]
          spec[:memoryHotAddEnabled] = attributes[:memoryHotAddEnabled]

          # Volumes
          device_change.concat(update_vm_volumes_specs(vm_mob_ref, server.volumes))

          # Networks
          device_change.concat(update_vm_interfaces_specs(vm_mob_ref, server.interfaces, datacenter))

          spec[:deviceChange] = device_change unless device_change.empty?

          vm_reconfig_hardware('instance_uuid' => attributes[:instance_uuid], 'hardware_spec' => spec) unless spec.empty?
        end

        private

        def update_vm_interfaces_specs(vm_mob_ref, fog_interfaces, datacenter)
          vm_nics = vm_mob_ref.config.hardware.device.grep(RbVmomi::VIM::VirtualEthernetCard)
          modified_nics = fog_interfaces.to_a.take(vm_nics.size)
          new_nics = fog_interfaces.to_a.drop(vm_nics.size)

          specs = []
          vm_nics.zip(modified_nics).each do |vm_nic, fog_nic|
            if fog_nic
              # Update the attributes on the existing nic
              backing = create_nic_backing(fog_nic, datacenter: datacenter)

              if nic_backing_different?(vm_nic.backing, backing)
                vm_nic.backing = backing
                specs << { operation: :edit, device: vm_nic }
              end
            else
              specs << {
                operation: :remove,
                device: vm_nic
              }
            end
          end

          specs.concat(new_nics.map { |nic| create_interface(nic, 0, :add, datacenter: datacenter) }) if new_nics.any?

          specs
        end

        def update_vm_volumes_specs(vm_mob_ref, volumes)
          vm_volumes = vm_mob_ref.config.hardware.device.grep(RbVmomi::VIM::VirtualDisk)
          modified_volumes = volumes.to_a.take(vm_volumes.size)
          new_volumes = volumes.to_a.drop(vm_volumes.size)

          specs = []
          vm_volumes.zip(modified_volumes).each do |vm_volume, fog_volume|
            if fog_volume
              update_volume_attributes(vm_volume, fog_volume)

              specs << { operation: :edit, device: vm_volume }
              next
            end

            specs << { operation: :remove, fileOperation: :destroy, device: vm_volume }
          end

          specs.concat(new_volumes.map { |volume| create_disk(volume) }) if new_volumes.any?

          specs
        end

        def update_volume_attributes(vm_volume, fog_volume)
          vm_volume.capacityInKB = fog_volume.size
          vm_volume.backing.diskMode = fog_volume.mode
          vm_volume.backing.thinProvisioned = fog_volume.thin
        end

        def nic_backing_different?(one, two)
          return true if one.class != two.class

          case one
          when RbVmomi::VIM::VirtualEthernetCardDistributedVirtualPortBackingInfo
            one.port.portgroupKey != two.port.portgroupKey || one.port.switchUuid != two.port.switchUuid
          when RbVmomi::VIM::VirtualEthernetCardNetworkBackingInfo
            one.deviceName != two.deviceName
          else
            false
          end
        end
      end

      class Mock
        def update_vm(_server)
          # TODO: - currently useless and tests need to be re-though on a whole.
          { 'task_state' => 'success' }
        end
      end
    end
  end
end
