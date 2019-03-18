module Fog
  module Vsphere
    class Compute
      class Real
        def vm_reconfig_volumes(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'
          raise ArgumentError, 'volumes is a required parameter' unless options.key? 'volumes'
          hardware_spec = {
            deviceChange: []
          }
          options['volumes'].each do |volume|
            hardware_spec[:deviceChange].push(create_disk(volume, :edit, filename: volume.filename))
          end
          vm_reconfig_hardware('instance_uuid' => options['instance_uuid'], 'hardware_spec' => hardware_spec)
        end
      end

      class Mock
        def vm_reconfig_volumes(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'
          raise ArgumentError, 'volumes is a required parameter' unless options.key? 'volumes'
          hardware_spec = {
            deviceChange: []
          }
          options['volumes'].each do |volume|
            hardware_spec[:deviceChange].push(operation: :edit,
                                              device: {
                                                backing: { diskMode: volume.mode, fileName: volume.filename },
                                                unitNumber: volume.unit_number,
                                                key: volume.key,
                                                controllerKey: volume.controller_key,
                                                capacityInKB: volume.size
                                              })
          end
          vm_reconfig_hardware('instance_uuid' => options['instance_uuid'], 'hardware_spec' => hardware_spec)
        end
      end
    end
  end
end
