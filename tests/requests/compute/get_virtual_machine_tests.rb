require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_virtual_machine' do
    it 'gets virtual machine by uuid' do
      with_webmock_cassette('get_virtual_machine') do
        vm = compute.get_virtual_machine('52d810bd-077b-368d-a86f-0b2ad84269f8', 'BRQ')
        assert_equal(vm['name'], 'DC1')
      end
    end
  end
end
