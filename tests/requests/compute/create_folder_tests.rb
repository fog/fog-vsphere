require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#create_folder' do
    it 'creates folder' do
      with_webmock_cassette('create_folder') do
        folder = compute.create_folder('BRQ', '/', 'TestFolder')
        assert_equal(folder, 'TestFolder')
      end
    end
  end
end
