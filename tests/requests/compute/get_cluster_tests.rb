require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_cluster' do
    it 'gets cluster' do
      with_webmock_cassette('get_cluster') do
        cluster = compute.get_cluster('esxi.example.com', 'BRQ')
        assert_equal(cluster[:name], 'esxi.example.com')
      end
    end
  end
end
