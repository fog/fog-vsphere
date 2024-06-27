require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_vm_first_nvme_controller' do
    it 'gets virtual machine by uuid' do
      with_webmock_cassette('get_vm_first_nvme_controller') do
        controller = compute.get_vm_first_nvme_controller('500daa1c-abaf-7fe3-1a4a-5ce47e6f2b0a')
        assert_equal(controller[:type], 'VirtualNVMEController')
      end
    end
  end
end
