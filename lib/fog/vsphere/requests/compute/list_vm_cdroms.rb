module Fog
  module Compute
    class Vsphere
      class Real
        def list_vm_cdroms(vm_id)
          get_vm_ref(vm_id).config.hardware.device.select { |hw| hw.class == RbVmomi::VIM::VirtualCdrom }.map do |cdrom|
            {
              filename: (begin
                              cdrom.backing.fileName
                            rescue
                              (nil)
                            end),
              name: cdrom.deviceInfo.label,
              key: cdrom.key,
              controller_key: cdrom.controllerKey,
              unit_number: cdrom.unitNumber,
              start_connected: cdrom.connectable.startConnected,
              allow_guest_control: cdrom.connectable.allowGuestControl,
              connected: cdrom.connectable.connected,
              instance_uuid: vm_id
            }
          end
        end
      end
      class Mock
        def list_vm_cdroms(vm_id)
          raise Fog::Compute::Vsphere::NotFound, 'VM not Found' unless data[:servers].key?(vm_id)
          return [] unless data[:servers][vm_id].key?('cdroms')
          data[:servers][vm_id]['cdroms'].map { |h| h.merge(instance_uuid: vm_id) }
        end
      end
    end
  end
end
