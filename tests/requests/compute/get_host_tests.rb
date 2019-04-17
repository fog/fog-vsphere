require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_host' do
    it 'gets host' do
      with_webmock_cassette('get_host') do
        host = compute.get_host('esxi.example.com', 'esxi.example.com', 'BRQ')
        assert_equal(host[:name], 'esxi.example.com')
      end
    end
  end
end
