require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_vm_first_sata_controller' do
    it 'gets virtual machine by uuid' do
      with_webmock_cassette('get_vm_first_sata_controller') do
        controller = compute.get_vm_first_sata_controller('5030c6ce-c0b1-59d9-34ff-d8438e2f0339')
        assert_equal(controller[:type], 'VirtualAHCIController')
      end
    end
  end
end
