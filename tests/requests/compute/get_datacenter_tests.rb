require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_datacenter' do
    it 'gets datacenter' do
      with_webmock_cassette('get_datacenter') do
        dc = compute.get_datacenter('BRQ')
        assert_equal(dc[:name], 'BRQ')
      end
    end
  end
end
