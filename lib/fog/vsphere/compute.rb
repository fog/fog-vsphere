require 'digest/sha2'
# rubocop:disable Lint/RescueWithoutErrorClass
# rubocop:disable Metrics/ModuleLength
module Fog
  module Vsphere
    class Compute < Fog::Service
      requires :vsphere_username, :vsphere_password, :vsphere_server
      recognizes :vsphere_port, :vsphere_path, :vsphere_ns
      recognizes :vsphere_rev, :vsphere_ssl, :vsphere_expected_pubkey_hash
      recognizes :vsphere_debug

      model_path 'fog/vsphere/models/compute'
      model :server
      collection :servers
      model :servertype
      collection :servertypes
      model :datacenter
      collection :datacenters
      model :interface
      collection :interfaces
      model :interfacetype
      collection :interfacetypes
      model :volume
      collection :volumes
      model :snapshot
      collection :snapshots
      model :template
      collection :templates
      model :cluster
      collection :clusters
      model :resource_pool
      collection :resource_pools
      model :network
      collection :networks
      model :datastore
      collection :datastores
      model :storage_pod
      collection :storage_pods
      model :folder
      collection :folders
      model :customvalue
      collection :customvalues
      model :customfield
      collection :customfields
      model :scsicontroller
      model :nvmecontroller
      model :process
      model :cdrom
      collection :cdroms
      model :rule
      collection :rules
      model :host
      collection :hosts
      model :ticket
      collection :tickets

      request_path 'fog/vsphere/requests/compute'
      request :current_time
      request :cloudinit_to_customspec
      request :list_virtual_machines
      request :vm_power_off
      request :vm_power_on
      request :vm_suspend
      request :vm_reboot
      request :vm_clone
      request :vm_destroy
      request :vm_migrate
      request :vm_execute
      request :list_datacenters
      request :get_datacenter
      request :list_clusters
      request :get_cluster
      request :list_resource_pools
      request :get_resource_pool
      request :create_resource_pool
      request :update_resource_pool
      request :destroy_resource_pool
      request :list_networks
      request :get_network
      request :list_datastores
      request :get_datastore
      request :list_storage_pods
      request :get_storage_pod
      request :list_compute_resources
      request :get_compute_resource
      request :list_templates
      request :get_template
      request :get_folder
      request :list_folders
      request :create_vm
      request :update_vm
      request :list_vm_interfaces
      request :modify_vm_interface
      request :modify_vm_volume
      request :modify_vm_cdrom
      request :list_vm_volumes
      request :list_vm_cdroms
      request :get_virtual_machine
      request :vm_reconfig_hardware
      request :vm_reconfig_memory
      request :vm_reconfig_volumes
      request :vm_reconfig_cpus
      request :vm_reconfig_cdrom
      request :vm_rename
      request :vm_config_vnc
      request :create_folder
      request :list_server_types
      request :get_server_type
      request :list_interface_types
      request :get_interface_type
      request :list_vm_customvalues
      request :list_customfields
      request :get_vm_first_scsi_controller
      request :list_vm_scsi_controllers
      request :list_vm_nvme_controllers
      request :set_vm_customvalue
      request :vm_take_snapshot
      request :list_vm_snapshots
      request :list_child_snapshots
      request :revert_to_snapshot
      request :list_processes
      request :upload_iso
      request :folder_destroy
      request :create_rule
      request :list_rules
      request :destroy_rule
      request :list_hosts
      request :create_group
      request :list_groups
      request :destroy_group
      request :get_host
      request :modify_vm_controller
      request :vm_revert_snapshot
      request :vm_remove_snapshot
      request :vm_acquire_ticket
      request :vm_relocate
      request :host_shutdown
      request :host_start_maintenance
      request :host_finish_maintenance
      request :get_vm_first_sata_controller
      request :get_vm_first_nvme_controller

      module Shared
        attr_reader :vsphere_is_vcenter
        attr_reader :vsphere_rev
        attr_reader :vsphere_server
        attr_reader :vsphere_username

        protected

        ATTR_TO_PROP = {
          id: 'config.instanceUuid',
          name: 'name',
          uuid: 'config.uuid',
          template: 'config.template',
          parent: 'parent',
          hostname: 'summary.guest.hostName',
          operatingsystem: 'summary.guest.guestFullName',
          virtual_tpm: 'summary.config.tpmPresent',
          ipaddress: 'guest.ipAddress',
          power_state: 'runtime.powerState',
          connection_state: 'runtime.connectionState',
          hypervisor: 'runtime.host',
          tools_state: 'guest.toolsStatus',
          tools_version: 'guest.toolsVersionStatus',
          memory_mb: 'config.hardware.memoryMB',
          cpus: 'config.hardware.numCPU',
          disks: 'config.hardware.device',
          partitions:  'guest.disk',
          corespersocket: 'config.hardware.numCoresPerSocket',
          overall_status: 'overallStatus',
          guest_id: 'config.guestId',
          hardware_version: 'config.version',
          cpuHotAddEnabled: 'config.cpuHotAddEnabled',
          memoryHotAddEnabled: 'config.memoryHotAddEnabled',
          firmware: 'config.firmware',
          secure_boot: 'config.bootOptions.efiSecureBootEnabled',
          boot_order: 'config.bootOptions.bootOrder',
          annotation: 'config.annotation',
          extra_config: 'config.extraConfig'
        }.freeze

        def convert_vm_view_to_attr_hash(vms)
          vms = connection.serviceContent.propertyCollector.collectMultiple(vms, *ATTR_TO_PROP.values.uniq)
          vms.map { |vm| props_to_attr_hash(*vm) }
        end

        # Utility method to convert a VMware managed object into an attribute hash.
        # This should only really be necessary for the real class.
        # This method is expected to be called by the request methods
        # in order to massage VMware Managed Object References into Attribute Hashes.
        def convert_vm_mob_ref_to_attr_hash(vm_mob_ref)
          return nil unless vm_mob_ref

          props = vm_mob_ref.collect!(*ATTR_TO_PROP.values.uniq)
          props_to_attr_hash vm_mob_ref, props
        end

        # rubocop:disable Metrics/MethodLength
        def props_to_attr_hash(vm_mob_ref, props)
          # NOTE: Object.tap is in 1.8.7 and later.
          # Here we create the hash object that this method returns, but first we need
          # to add a few more attributes that require additional calls to the vSphere
          # API. The hypervisor name and mac_addresses attributes may not be available
          # so we need catch any exceptions thrown during lookup and set them to nil.
          #
          # The use of the "tap" method here is a convenience, it allows us to update the
          # hash object without explicitly returning the hash at the end of the method.
          Hash[ATTR_TO_PROP.map { |k, v| [k.to_s, props[v]] }].tap do |attrs|
            attrs['id'] ||= vm_mob_ref._ref
            attrs['mo_ref'] = vm_mob_ref._ref
            # The name method "magically" appears after a VM is ready and
            # finished cloning.
            attrs['boot_order'] = parse_boot_order(attrs['boot_order'])

            if attrs['hypervisor'].is_a?(RbVmomi::VIM::HostSystem)
              host = attrs['hypervisor']

              # @note
              #   - User might not have permission to access host
              #   - i.e. host.name might raise NoPermission error
              has_permission_to_access_host = true
              begin
                host.name
              rescue RbVmomi::Fault => e
                raise e unless e.message && e.message['NoPermission:']
                has_permission_to_access_host = false
              end

              attrs['datacenter'] = proc {
                begin
                  if has_permission_to_access_host
                    parent_attribute(host.path, :datacenter)[1]
                  else
                    parent_attribute(vm_mob_ref.path, :datacenter)[1]
                  end
                rescue
                  nil
                end
              }
              attrs['cluster'] = proc {
                begin
                           parent_attribute(host.path, :cluster)[1]
                         rescue
                           nil
                         end
              }
              attrs['hypervisor'] = proc {
                begin
                           host.name
                         rescue
                           nil
                         end
              }
              attrs['resource_pool'] = proc {
                begin
                          (vm_mob_ref.resourcePool || host.resourcePool).name
                        rescue
                          nil
                        end
              }

              attrs['disks'] = parse_disks(attrs['disks'])
              attrs['partitions'] = parse_partitions(attrs['partitions'])
              attrs['extra_config'] = parse_extra_config(attrs['extra_config'])
            end
            # This inline rescue catches any standard error.  While a VM is
            # cloning, a call to the macs method will throw and NoMethodError
            attrs['mac_addresses'] = proc {
              begin
                        vm_mob_ref.macs
                      rescue
                        nil
                      end
            }
            # Rescue nil to catch testing while vm_mob_ref isn't reaL??
            attrs['path'] = begin
                              '/' + attrs['parent'].path.map(&:last).join('/')
                            rescue
                              nil
                            end
          end
        end

        # returns the parent object based on a type
        # provides both real RbVmomi object and its name.
        # e.g.
        # [Datacenter("datacenter-2"), "dc-name"]
        # rubocop:enable Metrics/MethodLength
        def parent_attribute(path, type)
          element = case type
                    when :datacenter
                      RbVmomi::VIM::Datacenter
                    when :cluster
                      RbVmomi::VIM::ComputeResource
                    when :host
                      RbVmomi::VIM::HostSystem
                    else
                      raise 'Unknown type'
                    end
          path.select { |x| x[0].is_a? element }.flatten
        rescue
          nil
        end

        # Maps RbVmomi boot order values to fog understandable strings.
        # Result is uniqued, what effectively means that the order is defined by the first occurence.
        def parse_boot_order(vm_boot_devs)
          return unless vm_boot_devs.is_a?(Array)
          vm_boot_devs.map do |vm_boot_dev|
            case vm_boot_dev
            when RbVmomi::VIM::VirtualMachineBootOptionsBootableEthernetDevice
              'network'
            when RbVmomi::VIM::VirtualMachineBootOptionsBootableDiskDevice
              'disk'
            when RbVmomi::VIM::VirtualMachineBootOptionsBootableCdromDevice
              'cdrom'
            when RbVmomi::VIM::VirtualMachineBootOptionsBootableFloppyDevice
              'floppy'
            end
          end.compact.uniq
        end

        # Flattens Array of RbVmomi::VIM::OptionValue to simple hash
        def parse_extra_config(vm_extra_config)
          return unless vm_extra_config.is_a?(Array)
          vm_extra_config.map { |entry| [entry[:key], entry[:value]] }.to_h
        end

        def parse_disks(vm_disks)
          return unless vm_disks.is_a?(Array)
          vm_disks.grep(RbVmomi::VIM::VirtualDisk).map do |d|
            { :label => d.deviceInfo.label, :capacity => d.capacityInBytes }
          end
        end

        def parse_partitions(vm_partitions)
          return unless vm_partitions.is_a?(Array)
          vm_partitions.grep(RbVmomi::VIM::GuestDiskInfo).map do |p|
            { :path => p.diskPath, :free => p.freeSpace, :capacity => p.capacity }
          end
        end

        # returns vmware managed obj id string
        def managed_obj_id(obj)
          obj.to_s.match(/\("([^"]+)"\)/)[1]
        end

        def is_uuid?(id)
          id.is_a?(String) && /[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}/.match?(id)
        end
      end

      # rubocop:disable Metrics/ClassLength
      class Mock
        include Shared
        # rubocop:disable Metrics/MethodLength
        def self.data
          # rubocop:disable Metrics/BlockLength
          @data ||= Hash.new do |hash, key|
            hash[key] = {
              servers: {
                '5032c8a5-9c5e-ba7a-3804-832a03e16381' => {
                  'resource_pool'    => 'Resources',
                  'memory_mb'        => 2196,
                  'mac_addresses'    => { 'Network adapter 1' => '00:50:56:a9:00:28' },
                  'power_state'      => 'poweredOn',
                  'cpus'             => 1,
                  'hostname'         => 'dhcp75-197.virt.bos.redhat.com',
                  'mo_ref'           => 'vm-562',
                  'connection_state' => 'connected',
                  'overall_status'   => 'green',
                  'datacenter'       => 'Solutions',
                  'volumes'          =>
                    [{
                      'id'        => '6000C29c-a47d-4cd9-5249-c371de775f06',
                      'datastore' => 'Storage1',
                      'mode'      => 'persistent',
                      'size'      => 8_388_608,
                      'thin'      => true,
                      'name'      => 'Hard disk 1',
                      'filename'  => '[Storage1] rhel6-mfojtik/rhel6-mfojtik.vmdk',
                      'size_gb'   => 8
                    }],
                  'scsi_controllers' =>
                    [{ 'shared_bus' => 'noSharing',
                       'type'        => 'VirtualLsiLogicController',
                       'unit_number' => 7,
                       'key'         => 1000 }],
                  'nvme_controllers' =>
                       [{
                         'type'        => 'VirtualNVMEController',
                          'key'         => 2000
                       }],
                  'interfaces'       =>
                    [{ 'mac' => '00:50:56:a9:00:28',
                       'network' => 'dvportgroup-123456',
                       'name'    => 'Network adapter 1',
                       'status'  => 'ok',
                       'summary' => 'VM Network' }],
                  'cdroms' =>
                    [{
                      'name'                => 'CD-/DVD-Drive 1',
                      'filename'            => nil,
                      'key'                 => 3000,
                      'controller_key'      => 200,
                      'unit_number'         => 0,
                      'start_connected'     => false,
                      'allow_guest_control' => true,
                      'connected'           => false
                    }],
                  'hypervisor'       => 'gunab.puppetlabs.lan',
                  'guest_id'         => 'rhel6_64Guest',
                  'tools_state'      => 'toolsOk',
                  'cluster'          => 'Solutionscluster',
                  'name'             => 'rhel64',
                  'operatingsystem'  => 'Red Hat Enterprise Linux 6 (64-bit)',
                  'path'             => '/Datacenters/Solutions/vm',
                  'uuid'             => '4229f0e9-bfdc-d9a7-7bac-12070772e6dc',
                  'instance_uuid'    => '5032c8a5-9c5e-ba7a-3804-832a03e16381',
                  'id'               => '5032c8a5-9c5e-ba7a-3804-832a03e16381',
                  'tools_version'    => 'guestToolsUnmanaged',
                  'ipaddress'        => '192.168.100.184',
                  'template'         => false
                },
                '502916a3-b42e-17c7-43ce-b3206e9524dc' => {
                  'resource_pool'    => 'Resources',
                  'memory_mb'        => 512,
                  'power_state'      => 'poweredOn',
                  'mac_addresses'    => { 'Network adapter 1' => '00:50:56:a9:00:00' },
                  'hostname'         => nil,
                  'cpus'             => 1,
                  'connection_state' => 'connected',
                  'mo_ref'           => 'vm-621',
                  'overall_status'   => 'green',
                  'datacenter'       => 'Solutions',
                  'volumes'          =>
                    [{ 'thin' => false,
                       'size_gb'   => 10,
                       'datastore' => 'datastore1',
                       'filename'  => '[datastore1] i-1342439683/i-1342439683.vmdk',
                       'size'      => 10_485_762,
                       'name'      => 'Hard disk 1',
                       'mode'      => 'persistent',
                       'id'        => '6000C29b-f364-d073-8316-8e98ac0a0eae' }],
                  'scsi_controllers' =>
                    [{ 'shared_bus' => 'noSharing',
                       'type'        => 'VirtualLsiLogicController',
                       'unit_number' => 7,
                       'key'         => 1000 }],
                  'interfaces'       =>
                    [{ 'summary' => 'VM Network',
                       'mac'     => '00:50:56:a9:00:00',
                       'status'  => 'ok',
                       'network' => 'dvportgroup-123456',
                       'name'    => 'Network adapter 1' }],
                  'hypervisor'       => 'gunab.puppetlabs.lan',
                  'guest_id'         => nil,
                  'cluster'          => 'Solutionscluster',
                  'tools_state'      => 'toolsNotInstalled',
                  'name'             => 'i-1342439683',
                  'operatingsystem'  => nil,
                  'path'             => '/',
                  'tools_version'    => 'guestToolsNotInstalled',
                  'uuid'             => '4229e0de-30cb-ceb2-21f9-4d8d8beabb52',
                  'instance_uuid'    => '502916a3-b42e-17c7-43ce-b3206e9524dc',
                  'id'               => '502916a3-b42e-17c7-43ce-b3206e9524dc',
                  'ipaddress'        => nil,
                  'template'         => false
                },
                '5029c440-85ee-c2a1-e9dd-b63e39364603' => {
                  'resource_pool'    => 'Resources',
                  'memory_mb'        => 2196,
                  'power_state'      => 'poweredOn',
                  'mac_addresses'    => { 'Network adapter 1' => '00:50:56:b2:00:af' },
                  'hostname'         => 'centos56gm.localdomain',
                  'cpus'             => 1,
                  'connection_state' => 'connected',
                  'mo_ref'           => 'vm-715',
                  'overall_status'   => 'green',
                  'datacenter'       => 'Solutions',
                  'hypervisor'       => 'gunab.puppetlabs.lan',
                  'guest_id'         => 'rhel6_64Guest',
                  'cluster'          => 'Solutionscluster',
                  'tools_state'      => 'toolsOk',
                  'name'             => 'jefftest',
                  'operatingsystem'  => 'Red Hat Enterprise Linux 6 (64-bit)',
                  'path'             => '/Solutions/wibble',
                  'tools_version'    => 'guestToolsUnmanaged',
                  'ipaddress'        => '192.168.100.187',
                  'uuid'             => '42329da7-e8ab-29ec-1892-d6a4a964912a',
                  'instance_uuid'    => '5029c440-85ee-c2a1-e9dd-b63e39364603',
                  'id'               => '5029c440-85ee-c2a1-e9dd-b63e39364603',
                  'template'         => false
                }
              },
              datacenters: {
                'Solutions' => { name: 'Solutions', status: 'grey', path: ['Solutions'] }
              },
              datastores: {
                'Storage1' => {
                  'id' => 'datastore-123456',
                  'name' => 'Storage1',
                  'datacenter' => 'Solutions',
                  'type' => 'VMFS',
                  'freespace' => 697_471_860_736,
                  'accessible' => true,
                  'capacity' => 1_099_243_192_320,
                  'uncommitted' => 977_158_537_741,
                  'cluster' => []
                },
                'datastore1' => {
                  'id' => 'datastore-789123',
                  'name' => 'datastore1',
                  'datacenter' => 'Solutions',
                  'type' => 'VMFS',
                  'freespace' => 697_471_860_736,
                  'accessible' => true,
                  'capacity' => 1_099_243_192_320,
                  'uncommitted' => 977_158_537_741,
                  'cluster' => ['Solutionscluster']
                }
              },
              networks: {
                'network1' => {
                  'id' => 'dvportgroup-123456',
                  'name' => 'network1',
                  'datacenter' => 'Solutions',
                  'accessible' => true,
                  'virtualswitch' => nil,
                  'cluster' => ['Solutionscluster']
                },
                'network2' => {
                  'id' => 'dvportgroup-789123',
                  'name' => 'network2',
                  'datacenter' => 'Solutions',
                  'accessible' => true,
                  'virtualswitch' => nil,
                  'cluster' => []
                }
              },
              folders: {
                'wibble' => {
                  'name' => 'wibble',
                  'datacenter' => 'Solutions',
                  'path' => '/Solutions/wibble',
                  'type' => 'vm'
                },
                'empty' => {
                  'name' => 'empty',
                  'datacenter' => 'Solutions',
                  'path' => '/Solutions/empty',
                  'type' => 'vm'
                }
              },
              storage_pods:                 [{ id: 'group-p123456',
                                               name: 'Datastore Cluster 1',
                                               freespace: '4856891834368',
                                               capacity: '7132061630464',
                                               datacenter: 'Solutions' }],
              clusters:                 [{ id: '1d4d9a3f-e4e8-4c40-b7fc-263850068fa4',
                                           name: 'Solutionscluster',
                                           num_host: '4',
                                           num_cpu_cores: '16',
                                           overall_status: 'green',
                                           datacenter: 'Solutions',
                                           full_path: 'Solutionscluster',
                                           klass: 'RbVmomi::VIM::ComputeResource' },
                                         { id: 'e4195973-102b-4096-bbd6-5429ff0b35c9',
                                           name: 'Problemscluster',
                                           num_host: '4',
                                           num_cpu_cores: '32',
                                           overall_status: 'green',
                                           datacenter: 'Solutions',
                                           full_path: 'Problemscluster',
                                           klass: 'RbVmomi::VIM::ComputeResource' },
                                         {
                                           klass: 'RbVmomi::VIM::Folder',
                                           clusters: [{ id: '03616b8d-b707-41fd-b3b5-The first',
                                                        name: 'Problemscluster',
                                                        num_host: '4',
                                                        num_cpu_cores: '32',
                                                        overall_status: 'green',
                                                        datacenter: 'Solutions',
                                                        full_path: 'Nested/Problemscluster',
                                                        klass: 'RbVmomi::VIM::ComputeResource' },
                                                      { id: '03616b8d-b707-41fd-b3b5-the Second',
                                                        name: 'Lastcluster',
                                                        num_host: '8',
                                                        num_cpu_cores: '32',
                                                        overall_status: 'green',
                                                        datacenter: 'Solutions',
                                                        full_path: 'Nested/Lastcluster',
                                                        klass: 'RbVmomi::VIM::ComputeResource' }]
                                         }],
              rules: {
                'anti-affinity-foo' => {
                  datacenter: 'Solutions',
                  cluster: 'Solutionscluster',
                  key: 4242,
                  name: 'anti-affinity-foo',
                  enabled: true,
                  type: RbVmomi::VIM::ClusterAntiAffinityRuleSpec,
                  vm_ids: ['5032c8a5-9c5e-ba7a-3804-832a03e16381', '502916a3-b42e-17c7-43ce-b3206e9524dc']
                }
              },
              hosts: {
                'Host1' => {
                  datacenter: 'Solutions',
                  cluster: 'Solutionscluster',
                  name: 'host1.example.com',
                  model: 'PowerEdge R730',
                  vendor: 'Dell Inc.',
                  ipaddress: '1.2.3.4',
                  ipaddress6: nil,
                  hostname: 'host1',
                  domainname: 'example.com',
                  product_name: 'VMware ESXi',
                  uuid: '4c4c4544-0051-3610-8046-c4c44f584a32',
                  cpu_cores: 20,
                  cpu_sockets: 2,
                  cpu_threads: 40,
                  cpu_hz: 2_599_999_534,
                  memory: 824_597_241_856,
                  product_version: '6.0.0',
                  vm_ids: ['5032c8a5-9c5e-ba7a-3804-832a03e16381', '502916a3-b42e-17c7-43ce-b3206e9524dc']
                }
              }
            }
          end
          # rubocop:enable Metrics/BlockLength
        end

        # rubocop:enable Metrics/MethodLength
        def initialize(options = {})
          require 'rbvmomi'
          @vsphere_username = options[:vsphere_username]
          @vsphere_password = 'REDACTED'
          @vsphere_server   = options[:vsphere_server]
          @vsphere_expected_pubkey_hash = options[:vsphere_expected_pubkey_hash]
          @vsphere_is_vcenter = true
          @vsphere_rev = '4.0'
        end

        def data
          self.class.data[@vsphere_username]
        end

        def reset_data
          self.class.data.delete(@vsphere_username)
        end
      end
      # rubocop:enable Metrics/ClassLength

      class Real
        include Shared

        def initialize(options = {})
          require 'rbvmomi'
          @vsphere_username = options[:vsphere_username]
          @vsphere_password = options[:vsphere_password]
          @vsphere_server   = options[:vsphere_server]
          @vsphere_port     = options[:vsphere_port] || 443
          @vsphere_path     = options[:vsphere_path] || '/sdk'
          @vsphere_ns       = options[:vsphere_ns] || 'urn:vim25'
          @vsphere_rev      = options[:vsphere_rev] || '4.0'
          @vsphere_ssl      = options[:vsphere_ssl] || true
          @vsphere_debug    = options[:vsphere_debug] || false
          @vsphere_expected_pubkey_hash = options[:vsphere_expected_pubkey_hash]
          @vsphere_must_reauthenticate = false
          @vsphere_is_vcenter = nil
          @connection = nil
          connect
          negotiate_revision(options[:vsphere_rev])
          authenticate
        end

        def connection
          if @connection.nil? || @connection.serviceContent.sessionManager.currentSession.nil?
            Fog::Logger.debug('Reconnecting to vSphere.')
            @connection = nil
            reload
          end
          @connection
        end

        def reload
          connect
          # Check if the negotiation was ever run
          negotiate if @vsphere_is_vcenter.nil?
          authenticate
        end

        private

        def negotiate_revision(revision = nil)
          # Negotiate the API revision
          unless revision
            rev = @connection.serviceContent.about.apiVersion
            @connection.rev = [rev, ENV['FOG_VSPHERE_REV'] || '4.1'].max
          end

          @vsphere_is_vcenter = @connection.serviceContent.about.apiType == 'VirtualCenter'
          @vsphere_rev = @connection.rev
        end

        def connect
          # This is a state variable to allow digest validation of the SSL cert
          bad_cert = false
          loop do
            begin
              @connection = RbVmomi::VIM.new host: @vsphere_server,
                                             port: @vsphere_port,
                                             path: @vsphere_path,
                                             ns: @vsphere_ns,
                                             rev: @vsphere_rev,
                                             ssl: @vsphere_ssl,
                                             insecure: bad_cert,
                                             debug: @vsphere_debug

              # Create a shadow class to change the behaviour of @connection.obj2xml
              # so that xsd:any types are converted to xsd:int (and not xsd:long).
              #
              # This is a known issue with RbVmomi.
              #
              # See https://communities.vmware.com/message/2505334 for discussion
              # and https://github.com/rlane/rbvmomi/pull/30 for an unmerged
              # pull request that fixes it in RbVmomi.
              #
              class <<@connection
                def obj2xml(xml, name, type, is_array, o, attrs = {})
                  case o
                  when Integer
                    attrs['xsi:type'] = 'xsd:int' if type(type) == RbVmomi::BasicTypes::AnyType
                    xml.tag! name, o.to_s, attrs
                    xml
                  else
                    super xml, name, type, is_array, o, attrs
                  end
                end
              end

              break
            rescue OpenSSL::SSL::SSLError
              raise if bad_cert
              bad_cert = true
            end
          end

          validate_ssl_connection if bad_cert
        end

        def authenticate
          @connection.serviceContent.sessionManager.Login userName: @vsphere_username,
                                                          password: @vsphere_password
        rescue RbVmomi::VIM::InvalidLogin => e
          raise Fog::Vsphere::Errors::ServiceError, e.message
        end

        # Verify a SSL certificate based on the hashed public key
        def validate_ssl_connection
          pubkey = @connection.http.peer_cert.public_key
          pubkey_hash = Digest::SHA2.hexdigest(pubkey.to_s)
          expected_pubkey_hash = @vsphere_expected_pubkey_hash
          if pubkey_hash != expected_pubkey_hash
            raise Fog::Vsphere::Errors::SecurityError, "The remote system presented a public key with hash #{pubkey_hash} but we're expecting a hash of #{expected_pubkey_hash || '<unset>'}.  If you are sure the remote system is authentic set vsphere_expected_pubkey_hash: <the hash printed in this message> in ~/.fog"
          end
        end

        def list_container_view(datacenter_obj_or_name, type, container_object = nil)
          dc = if datacenter_obj_or_name.is_a?(String)
                 find_raw_datacenter(datacenter_obj_or_name)
               else
                 datacenter_obj_or_name
               end

          container = if container_object
                        dc.public_send(container_object)
                      else
                        dc
                      end

          container_view = connection.serviceContent.viewManager.CreateContainerView(
            container: dc,
            type: [type],
            recursive: true
          )

          result = container_view.view
          container_view.DestroyView
          result
        end
      end
    end
  end
end
