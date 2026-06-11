require_relative '../../helper'

require 'rbvmomi'
require 'fog/vsphere/models/compute/scsicontroller'
require 'fog/vsphere/requests/compute/create_vm'

describe Fog::Vsphere::Compute::Real do
  let(:real) { Fog::Vsphere::Compute::Real.allocate }

  describe '#create_controller' do
    it 'defaults to ParaVirtualSCSIController when no controller is given' do
      result = real.send(:create_controller)

      assert_equal(RbVmomi::VIM::ParaVirtualSCSIController, result[:device].class)
    end

    it 'defaults a freshly built SCSIController model to ParaVirtualSCSIController' do
      controller = Fog::Vsphere::Compute::SCSIController.new

      result = real.send(:create_controller, controller)

      assert_equal(RbVmomi::VIM::ParaVirtualSCSIController, result[:device].class)
    end

    %w[
      VirtualLsiLogicController
      VirtualLsiLogicSASController
      VirtualBusLogicController
    ].each do |legacy_type|
      it "still builds a #{legacy_type} when explicitly requested" do
        controller = Fog::Vsphere::Compute::SCSIController.new(:type => legacy_type)

        result = real.send(:create_controller, controller)

        assert_equal(RbVmomi::VIM.const_get(legacy_type), result[:device].class)
      end
    end
  end
end
