require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_template' do
    it 'gets template by uuid' do
      with_webmock_cassette('get_template') do
        vm = compute.get_template('503cb26a-3423-2e69-04a0-24c6ff4cde8b', 'SatQE-Datacenter')
        assert_equal(vm['name'], 'RHEL9')
      end
    end
  end
end
