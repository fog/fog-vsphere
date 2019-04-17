require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_storage_pod' do
    it 'gets storage pod' do
      with_webmock_cassette('get_storage_pod') do
        pod = compute.get_storage_pod('devNullNoDRS', 'BRQ')
        assert_equal(pod[:name], 'devNullNoDRS')
      end
    end
  end
end
