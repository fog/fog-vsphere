require_relative '../../helper'

require 'fog/vsphere/requests/compute/create_vm'

describe Fog::Vsphere::Compute::Real do
  let(:connection) { mock('RbVmomi::VIM') }

  before do
    Fog.unmock!
    Fog::Vsphere::Compute::Real.any_instance.stubs(:connect)
    Fog::Vsphere::Compute::Real.any_instance.stubs(:authenticate)
    Fog::Vsphere::Compute::Real.any_instance.stubs(:negotiate_revision)
    Fog::Vsphere::Compute::Real.any_instance.stubs(:connection).returns(connection)
  end
  after { Fog.mock! }

  let(:compute) { Fog::Compute.new(provider: :vsphere, vsphere_rev: '6.0') }

  describe '#create_vm' do
    let(:vm) { stub('config' => stub('instanceUuid' => 'SOME-UUID')) }
    let(:default_params) { { host: 'someesxi.example.com', name: 'NiceVmName', cluster: 'Cluster', datacenter: 'Datacenter' } }

    describe 'argument parsing' do
      let(:resource_pool) { stub }
      let(:folder) { stub }
      let(:host) { stub }

      before do
        Fog::Vsphere::Compute::Real.any_instance.stubs(:device_change).returns({})
        Fog::Vsphere::Compute::Real.any_instance.stubs(:vm_path_name).returns('[storage1]')
        Fog::Vsphere::Compute::Real.any_instance.stubs(:get_storage_pod_from_volumes).returns(nil)
        Fog::Vsphere::Compute::Real.any_instance.stubs(:get_raw_cluster).returns(stub('resourcePool' => resource_pool))
        Fog::Vsphere::Compute::Real.any_instance.stubs(:get_raw_vmfolder).returns(folder)
        Fog::Vsphere::Compute::Real.any_instance.stubs(:get_raw_host).returns(host)
      end

      it 'calls boot_options to parse boot_order' do
        arguments = default_params.merge(boot_order: ['disk', 'network'])
        boot_options = { bootOrder: [stub] }
        Fog::Vsphere::Compute::Real.any_instance
                                   .expects(:boot_options)
                                   .with(arguments, has_entry(:name, 'NiceVmName'))
                                   .returns(boot_options)
        Fog::Vsphere::Compute::Real.any_instance
                                   .expects(:create_vm_on_datastore)
                                   .with(has_entry(:bootOptions, boot_options), folder, resource_pool, host)
                                   .returns(vm)
        expect(compute.create_vm(arguments)).must_equal('SOME-UUID')
      end
    end
  end

  describe '#boot_order' do
    it 'adds all nics in order for network boot' do
      networks = [stub, stub, stub]
      nwrk_boot1 = stub
      nwrk_boot2 = stub
      nwrk_boot3 = stub

      RbVmomi::VIM::VirtualMachineBootOptionsBootableEthernetDevice.expects(:new).with(deviceKey: 4000).returns(nwrk_boot1)
      RbVmomi::VIM::VirtualMachineBootOptionsBootableEthernetDevice.expects(:new).with(deviceKey: 4001).returns(nwrk_boot2)
      RbVmomi::VIM::VirtualMachineBootOptionsBootableEthernetDevice.expects(:new).with(deviceKey: 4002).returns(nwrk_boot3)

      expect(
        compute.send(:boot_order, { boot_order: ['network'], interfaces: networks }, {})
      ).must_equal([nwrk_boot1, nwrk_boot2, nwrk_boot3])
    end

    it 'adds all disks in order for disk boot' do
      disk_devs = [
        { device: stub('key' => 23) },
        { device: stub('key' => 12) },
        { device: stub('key' => 34) }
      ]
      disk_devs.each { |d| d[:device].expects('is_a?').with(RbVmomi::VIM::VirtualDisk).returns(true) }
      disk_boot1 = stub
      disk_boot2 = stub
      disk_boot3 = stub

      RbVmomi::VIM::VirtualMachineBootOptionsBootableDiskDevice.expects(:new).with(deviceKey: 23).returns(disk_boot1)
      RbVmomi::VIM::VirtualMachineBootOptionsBootableDiskDevice.expects(:new).with(deviceKey: 12).returns(disk_boot2)
      RbVmomi::VIM::VirtualMachineBootOptionsBootableDiskDevice.expects(:new).with(deviceKey: 34).returns(disk_boot3)

      expect(
        compute.send(:boot_order, { boot_order: ['disk'] }, deviceChange: disk_devs)
      ).must_equal([disk_boot1, disk_boot2, disk_boot3])
    end
  end
end
