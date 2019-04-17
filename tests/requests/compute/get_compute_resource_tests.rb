require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_compute_resource' do
    it 'gets ComputeResource' do
      with_webmock_cassette('get_compute_resource') do
        cr = compute.get_compute_resource('esxi.example.com', 'BRQ')
        assert_equal(cr[:name], 'esxi.example.com')
      end
    end
  end
end
