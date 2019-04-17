Shindo.tests('Fog::Compute[:vsphere] | folder_destroy request', ['vsphere']) do
  compute = Fog::Compute[:vsphere]

  empty_folder = '/Solutions/empty'
  full_folder  = '/Solutions/wibble'
  datacenter   = 'Solutions'

  tests('The response should') do
    response = compute.folder_destroy(empty_folder, datacenter)
    test('be a kind of Hash') { response.is_a? Hash }
    test('should have a task_state key') { response.key? 'task_state' }
  end

  tests('When folder is not empty') do
    raises(Fog::Vsphere::Errors::ServiceError, 'raises ServiceError') do
      compute.folder_destroy(full_folder, datacenter)
    end
  end
end

require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#folder_destroy' do
    it 'destroys folder' do
      with_webmock_cassette('folder_destroy') do
        result = compute.folder_destroy('TestFolder', 'BRQ')
        assert_equal result['task_state'], 'success'
      end
    end
  end
end
