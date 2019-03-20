module Fog
  module Vsphere
    class Compute
      class Real
        def vm_migrate(options = {})
          # priority is the only required option, and it has a sane default option.
          priority = options['priority'].nil? ? 'defaultPriority' : options['priority']
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'

          # Find the VM Object
          search_filter = { :uuid => options['instance_uuid'], 'vmSearch' => true, 'instanceUuid' => true }
          vm_mob_ref = connection.searchIndex.FindAllByUuid(search_filter).first

          unless vm_mob_ref.is_a? RbVmomi::VIM::VirtualMachine
            raise Fog::Vsphere::Errors::NotFound,
                  "Could not find VirtualMachine with instance uuid #{options['instance_uuid']}"
          end
          options['host'] = get_raw_host(options['host'], options['cluster'], options['datacenter']) if options['host']
          task_options = { pool: options['pool'], host: options['host'], state: options['state'] }
          if options['check']
            checker = connection.serviceContent.vmProvisioningChecker
            task = checker.CheckMigrate_Task(task_options.merge(vm: vm_mob_ref))
            task.wait_for_completion
            { 'error' => task.info.result[0].error, 'warning' => task.info.result[0].warning }
          else
            task = vm_mob_ref.MigrateVM_Task(task_options.merge(priority: priority.to_s))
            task.wait_for_completion
            { 'task_state' => task.info.state }
          end
        end
      end

      class Mock
        def vm_migrate(options = {})
          priority = options['priority'].nil? ? 'defaultPriority' : options['priority']
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key? 'instance_uuid'
          { 'task_state' => 'success' }
        end
      end
    end
  end
end
