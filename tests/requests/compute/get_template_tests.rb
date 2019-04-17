require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_template' do
    it 'gets template by uuid' do
      with_webmock_cassette('get_template') do
        vm = compute.get_template('500e2be9-4762-1f52-5e7c-f37444be5f6e', 'BRQ')
        assert_equal(vm['name'], 'fedora29')
      end
    end
  end
end
