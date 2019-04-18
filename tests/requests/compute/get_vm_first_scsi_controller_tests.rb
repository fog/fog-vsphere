require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_vm_first_scsi_controller' do
    it 'gets virtual machine by uuid' do
      with_webmock_cassette('get_vm_first_scsi_controller') do
        controller = compute.get_vm_first_scsi_controller('52d810bd-077b-368d-a86f-0b2ad84269f8')
        assert_equal(controller.type, 'VirtualLsiLogicSASController')
      end
    end
  end
end
