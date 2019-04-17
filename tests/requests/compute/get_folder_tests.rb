require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_folder' do
    it 'gets any type of folder' do
      with_webmock_cassette('get_folder') do
        folder = compute.get_folder('TestFolder', 'BRQ', 'vm')
        assert_equal(folder[:name], 'TestFolder')

        folder = compute.get_folder('TestNwFolder', 'BRQ', 'network')
        assert_equal(folder[:name], 'TestNwFolder')

        folder = compute.get_folder('TestHostFolder', 'BRQ', 'host')
        assert_equal(folder[:name], 'TestHostFolder')

        folder = compute.get_folder('TestDsFolder', 'BRQ', 'datastore')
        assert_equal(folder[:name], 'TestDsFolder')
      end
    end
  end
end
