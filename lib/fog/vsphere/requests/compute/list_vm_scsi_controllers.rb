module Fog
  module Vsphere
    class Compute
      class Real
        def list_vm_scsi_controllers(vm_id)
          list_vm_scsi_controllers_raw(vm_id).map do |raw_controller|
            Fog::Vsphere::Compute::SCSIController.new(raw_controller)
          end
        end

        def list_vm_scsi_controllers_raw(vm_id)
          get_vm_ref(vm_id).config.hardware.device.grep(RbVmomi::VIM::VirtualSCSIController).map do |ctrl|
            {
              type: ctrl.class.to_s,
              shared_bus: ctrl.sharedBus.to_s,
              unit_number: ctrl.scsiCtlrUnitNumber,
              key: ctrl.key
            }
          end
        end
      end
      class Mock
        def list_vm_scsi_controllers(vm_id)
          raise Fog::Vsphere::Compute::NotFound, 'VM not Found' unless data[:servers].key?(vm_id)
          return [] unless data[:servers][vm_id].key?('scsi_controllers')
          data[:servers][vm_id]['scsi_controllers'].map { |h| h.merge(server_id: vm_id) }
        end
      end
    end
  end
end
