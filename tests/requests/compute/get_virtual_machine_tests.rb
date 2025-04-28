require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_virtual_machine' do
    it 'gets virtual machine by uuid' do
      with_webmock_cassette('get_virtual_machine') do
        vm = compute.get_virtual_machine('503ccdc6-7242-8b3a-6b69-c2cc3b60f094', 'SatQE-Datacenter')
        assert_equal(vm['name'], 'SatQE-NFS-Datastore')
      end
    end
  end
end
