module Fog
  module Vsphere
    class Compute
      class Real
        def get_vm_first_nvme_controller(vm_id)
          ctrl = get_vm_ref(vm_id).config.hardware.device.find { |device| device.is_a?(RbVmomi::VIM::VirtualNVMEController) }
          raise Fog::Vsphere::Compute::NotFound, "No NVME controller found for #{vm_id}" unless ctrl
          {
            type: ctrl&.class.to_s,
            device_info: ctrl&.deviceInfo,
            bus_number: ctrl&.busNumber,
            key: ctrl&.key
          }
        end
      end
      class Mock
        def get_vm_first_nvme_controller(vm_id); end
      end
    end
  end
end
