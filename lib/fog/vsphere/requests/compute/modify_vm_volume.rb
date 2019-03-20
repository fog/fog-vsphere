module Fog
  module Vsphere
    class Compute
      class Real
        def add_vm_volume(volume)
          vm_reconfig_hardware('instance_uuid' => volume.server_id, 'hardware_spec' => { 'deviceChange' => [create_disk(volume, :add)] })
        end

        def remove_vm_volume(volume)
          vm_reconfig_hardware('instance_uuid' => volume.server_id, 'hardware_spec' => { 'deviceChange' => [create_disk(volume, :remove)] })
        end

        def destroy_vm_volume(volume)
          vm_reconfig_hardware('instance_uuid' => volume.server_id, 'hardware_spec' => {
                                 'deviceChange' => [create_disk(volume, :remove, file_operation: :destroy)]
                               })
        end
      end

      class Mock
        def add_vm_volume(volume)
          vm_reconfig_hardware('instance_uuid' => volume.server_id, 'hardware_spec' => { 'deviceChange' => [create_cdrom(volume, :add)] })
        end

        def remove_vm_volume(_volume)
          true
        end

        def destroy_vm_volume(_volume)
          true
        end
      end
    end
  end
end
