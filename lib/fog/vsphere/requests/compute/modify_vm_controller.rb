module Fog
  module Compute
    class Vsphere
      class Real
        def add_vm_controller(controller)
          options = {}
          options[:operation] = 'add'
          options[:type] = controller.type
          options[:key] = controller.key
          options[:shared] = controller.shared_bus

          vm_reconfig_hardware('instance_uuid' => controller.server_id, 'hardware_spec' => {'deviceChange'=>[create_controller(options)]})
        end
      end

      class Mock
        def add_vm_controller(controller)
          options = {}
          options[:operation] = 'add'
          options[:type] = RbVmomi::VIM.VirtualLsiLogicController.class
          options[:key] = 1000
          options[:shared] = false

          vm_reconfig_hardware('instance_uuid' => controller.server_id, 'hardware_spec' => {'deviceChange'=>[create_controller(options)]})
        end
      end
    end
  end
end
