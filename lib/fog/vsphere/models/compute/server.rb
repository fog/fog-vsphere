require 'fog/compute/models/server'

module Fog
  module Compute
    class Vsphere
      class Server < Fog::Compute::Server
        extend Fog::Deprecation
        deprecate(:ipaddress, :public_ip_address)
        deprecate(:scsi_controller, :scsi_controllers)

        # This will be the instance uuid which is globally unique across
        # a vSphere deployment.
        identity  :id

        # JJM REVISIT (Extend the model of a vmware server)
        # SEE: http://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.VirtualMachine.html
        # (Take note of the See also section.)
        # In particular:
        #   GuestInfo: information about the guest operating system
        #   VirtualMachineConfigInfo: Access to the VMX file and configuration

        attribute :name
        # UUID may be the same from VM to VM if the user does not select (I copied it)
        attribute :uuid
        attribute :hostname
        attribute :operatingsystem
        attribute :public_ip_address, :aliases => 'ipaddress'
        attribute :power_state,   :aliases => 'power'
        attribute :tools_state,   :aliases => 'tools'
        attribute :tools_version
        attribute :mac_addresses, :aliases => 'macs'
        attribute :hypervisor,    :aliases => 'host'
        attribute :connection_state
        attribute :mo_ref
        attribute :path
        attribute :memory_mb
        attribute :cpus
        attribute :corespersocket
        attribute :interfaces
        attribute :volumes
        attribute :customvalues
        attribute :overall_status, :aliases => 'status'
        attribute :cluster
        attribute :datacenter
        attribute :resource_pool
        attribute :instance_uuid # move this --> id
        attribute :guest_id
        attribute :hardware_version
        attribute :scsi_controllers, :type => :array
        attribute :cpuHotAddEnabled
        attribute :memoryHotAddEnabled
        attribute :firmware
        attribute :annotation

        def initialize(attributes={} )
          super defaults.merge(attributes)
          self.instance_uuid ||= id # TODO: remvoe instance_uuid as it can be replaced with simple id
          initialize_interfaces
          initialize_volumes
          initialize_customvalues
          initialize_scsi_controllers
        end

        # Lazy Loaded Attributes
        [:datacenter, :cluster, :hypervisor, :resource_pool, :mac_addresses].each do |attr|
          define_method attr do
            attributes[attr] = attributes[attr].call if attributes[attr].is_a?(Proc)
            attributes[attr]
          end
        end
        # End Lazy Loaded Attributes

        def vm_rename
          requires :instance_uuid, :name
          service.vm_rename('instance_uuid' => instance_uuid, 'name' => name)
        end

        def vm_reconfig_memory(options = {})
          requires :instance_uuid, :memory
          service.vm_reconfig_memory('instance_uuid' => instance_uuid, 'memory' => memory_mb)
        end

        def vm_reconfig_cpus(options = {})
          requires :instance_uuid, :cpus, :corespersocket
          service.vm_reconfig_cpus('instance_uuid' => instance_uuid, 'cpus' => cpus, 'corespersocket' => corespersocket)
        end

        def vm_reconfig_volumes(options = {})
          requires :instance_uuid, :volumes
          service.vm_reconfig_volumes('instance_uuid' => instance_uuid, 'volumes' => volumes)
        end

        def vm_reconfig_hardware(hardware_spec, options = {})
          requires :instance_uuid
          service.vm_reconfig_hardware('instance_uuid' => instance_uuid, 'hardware_spec' => hardware_spec)
        end

        def start(options = {})
          requires :instance_uuid
          service.vm_power_on('instance_uuid' => instance_uuid) unless ready?
        end

        def stop(options = {})
          options = { :force => !tools_installed? || !tools_running? }.merge(options)
          requires :instance_uuid
          service.vm_power_off('instance_uuid' => instance_uuid, 'force' => options[:force]) unless power_state == 'poweredOff'
        end

        def suspend(options = {})
          options = { :force => !tools_installed? || !tools_running? }.merge(options)
          requires :instance_uuid
          service.vm_suspend('instance_uuid' => instance_uuid, 'force' => options[:force])
        end

        def reboot(options = {})
          options = { :force => false }.merge(options)
          requires :instance_uuid
          service.vm_reboot('instance_uuid' => instance_uuid, 'force' => options[:force])
        end

        def destroy(options = {})
          requires :instance_uuid
          if ready?
            # need to turn it off before destroying
            stop(options)
            wait_for { !ready? }
          end
          service.vm_destroy('instance_uuid' => instance_uuid)
        end

        def migrate(options = {})
          options = { :priority => 'defaultPriority' }.merge(options)
          requires :instance_uuid

          # Convert symbols to strings
          req_options = options.reduce({}) { |hsh, (k,v)| hsh[k.to_s] = v; hsh }
          req_options['cluster'] ||= cluster
          req_options['datacenter'] = "#{datacenter}"
          req_options['instance_uuid'] = instance_uuid
          
          service.vm_migrate(req_options)
        end

        # Clone from a server object
        #
        # ==== Parameters
        # *<~Hash>:
        #   * 'name'<~String> - *REQUIRED* Name of the _new_ VirtualMachine
        #   * See more options in vm_clone request/compute/vm_clone.rb
        #
        def clone(options = {})
          requires :name, :datacenter, :path

          # Convert symbols to strings
          req_options = options.reduce({}) { |hsh, (k,v)| hsh[k.to_s] = v; hsh }

          # Give our path to the request
          req_options['template_path'] ="#{relative_path}/#{name}"
          req_options['datacenter'] = "#{datacenter}"

          # Perform the actual clone
          clone_results = service.vm_clone(req_options)

          # We need to assign the service, otherwise we can't reload the model
          # Create the new VM model. TODO This only works when "wait=true"
          new_vm = self.class.new(clone_results['new_vm'].merge(:service => self.service))

          # We need to assign the collection otherwise we
          # cannot reload the model.
          new_vm.collection = self.collection

          # Return the new VM model.
          new_vm
        end

        def take_snapshot(options = {})
          requires :instance_uuid
          service.vm_take_snapshot(options.merge('instance_uuid' => instance_uuid))
        end

        def ready?
          power_state == "poweredOn"
        end

        def tools_installed?
          !(tools_state == 'toolsNotInstalled' || tools_version == 'guestToolsNotInstalled')
        end

        def tools_running?
          ["toolsOk","toolsOld"].include? tools_state
        end

        # defines VNC attributes on the hypervisor
        def config_vnc(options = {})
          requires :instance_uuid
          service.vm_config_vnc(options.merge('instance_uuid' => instance_uuid))
        end

        # returns a hash of VNC attributes required for service
        def vnc
          requires :instance_uuid
          service.vm_get_vnc(instance_uuid)
        end

        def memory
          memory_mb * 1024 * 1024
        end

        def sockets
          cpus / corespersocket
        end

        def mac
          interfaces.first.mac unless interfaces.empty?
        end

        def interfaces
          attributes[:interfaces] ||= id.nil? ? [] : service.interfaces( :server_id => self.id )
        end

        def interface_ready? attrs
          (attrs.is_a? Hash and attrs[:blocking]) or attrs.is_a? Fog::Compute::Vsphere::Interface
        end

        def add_interface attrs
          Fog::Logger.deprecation("<server>.add_interface is deprecated. Call <server>.interfaces.create instead.")

          interfaces.create(attrs)
        end

        def update_interface attrs
          wait_for { not ready? } if interface_ready? attrs
          service.update_vm_interface(id, attrs)
        end

        def destroy_interface attrs
          Fog::Logger.deprecation("<server>.destroy_vm_interface is deprecated. Call <server>.interfaces.get(:key => <nic_key>).destroy instead.")

          interfaces.get(attrs[:key] || attrs['key']).destroy
        end

        def volumes
          attributes[:volumes] ||= id.nil? ? [] : service.volumes(:server_id => self.id)
        end

        def snapshots(opts = {})
          service.snapshots(:server_id => self.id).all(opts)
        end

        def find_snapshot(snapshot_ref)
          snapshots.get(snapshot_ref)
        end

        def revert_snapshot(snapshot)
          case snapshot
          when Snapshot
            service.revert_to_snapshot(snapshot)
          when String
            service.revert_to_snapshot(find_snapshot(snapshot))
          else
            fail ArgumentError, "snapshot has to be kind of Snapshot or String class"
          end
        end

        def cdroms(opts = {})
          service.cdroms(:instance_uuid => self.id).all(opts)
        end

        def cdrom(key)
          cdroms.get(key)
        end

        def guest_processes(opts = {})
          fail 'VM tools must be running' unless tools_running?
          service.list_processes(self.id, opts)
        end

        def customvalues
          attributes[:customvalues] ||= id.nil? ? [] : service.customvalues( :vm => self )
        end

        def scsi_controllers
          self.attributes[:scsi_controllers] ||= service.list_vm_scsi_controllers(id)
        end

        def scsi_controller
          scsi_controllers.first
        end

        def folder
          return nil unless datacenter and path
          attributes[:folder] ||= service.folders(:datacenter => datacenter, :type => :vm).get(path)
        end

        def save
          requires :name, :cluster, :datacenter
          if persisted?
            vm_rename if attribute_changed?(:name)
            vm_reconfig_cpus if attribute_changed?(:cpus) || attribute_changed?(:corespersocket)
            vm_reconfig_memory if attribute_changed?(:memory_mb)
            vm_reconfig_volumes if attribute_changed?(:volumes)
          else
            self.id = service.create_vm(attributes)
          end
          @old = nil
          reload
        end

        def new?
          id.nil?
        end

        def reload
          # reload does not re-read assoiciated attributes, so we clear it manually
          [:interfaces, :volumes].each do |attr|
            self.attributes.delete(attr)
          end
          super
        end

        def relative_path
          requires :path, :datacenter

          (path.split('/').reject {|e| e.empty?} - ["Datacenters", datacenter, "vm"]).join("/")
        end

        def acquire_ticket(type = nil)
          service.tickets(:server => self).create
        end

        private

        def defaults
          {
            :cpus      => 1,
#            :corespersocket => 1,
            :memory_mb => 512,
            :guest_id  => 'otherGuest',
            :path      => '/'
          }
        end

        def initialize_interfaces
          if attributes[:interfaces] and attributes[:interfaces].is_a?(Array)
            self.attributes[:interfaces].map! { |nic| nic.is_a?(Hash) ? service.interfaces.new(nic) : nic }
          end
        end

        def initialize_volumes
          if attributes[:volumes] and attributes[:volumes].is_a?(Array)
            self.attributes[:volumes].map! { |vol| vol.is_a?(Hash) ? service.volumes.new({:server => self}.merge(vol)) : vol }
          end
        end

        def initialize_customvalues
          if attributes[:customvalues] and attributes[:customvalues].is_a?(Array)
            self.attributes[:customvalues].map { |cfield| cfield.is_a?(Hash) ? service.customvalue.new(cfield) : cfield}
          end
        end

        def initialize_scsi_controllers
          if attributes[:scsi_controllers] && attributes[:scsi_controllers].is_a?(Array)
            self.attributes[:scsi_controllers].map! do |controller|
              controller.is_a?(Hash) ? Fog::Compute::Vsphere::SCSIController.new(controller) : controller
            end
          elsif attributes[:scsi_controller] && attributes[:scsi_controller].is_a?(Hash)
            self.attributes[:scsi_controllers] = [
              Fog::Compute::Vsphere::SCSIController.new(self.attributes[:scsi_controller])
            ]
          elsif attributes[:volumes] && attributes[:volumes].is_a?(Array) && !attributes[:volumes].empty?
            # Create a default scsi controller if there are any disks but no controller defined
            self.attributes[:scsi_controllers] = [
              Fog::Compute::Vsphere::SCSIController.new
            ]
          end
        end

        def attribute_changed?(attr)
          self.attributes.select { |k, v| old.attributes[k] != v }.key?(attr)
        end

        def old
          @old ||= self.dup.reload
        end
      end
    end
  end
end
