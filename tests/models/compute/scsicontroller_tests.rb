require_relative '../../helper'

require 'fog/vsphere/models/compute/scsicontroller'

describe Fog::Vsphere::Compute::SCSIController do
  describe '#type' do
    it 'defaults to ParaVirtualSCSIController when not given a type' do
      controller = Fog::Vsphere::Compute::SCSIController.new

      assert_equal('ParaVirtualSCSIController', controller.type)
    end

    %w[
      VirtualLsiLogicController
      VirtualLsiLogicSASController
      VirtualBusLogicController
    ].each do |legacy_type|
      it "preserves an explicitly requested #{legacy_type}" do
        controller = Fog::Vsphere::Compute::SCSIController.new(:type => legacy_type)

        assert_equal(legacy_type, controller.type)
      end
    end
  end
end
