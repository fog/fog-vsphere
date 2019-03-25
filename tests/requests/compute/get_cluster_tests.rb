require_relative '../../test_helper'

describe Fog::Vsphere::Compute::Real do
  include Fog::Vsphere::TestHelper

  before { Fog.unmock! }
  after { Fog.mock! }

  let(:compute) { prepare_compute }

  describe '#get_cluster' do
    before do
      stub_request_with_files('get_cluster/compute_resource_search')
      stub_request_with_files('get_cluster/compute_resource_listing')
      stub_request_with_files('get_cluster/cluster_path')
      stub_request_with_files('get_cluster/cluster_path2')
    end

    it 'gets cluster' do
      summary_stub = stub_request_with_files('get_cluster/cluster_summary')

      cluster = compute.get_cluster('ESXiHost', 'MainDatacenter')

      # TODO: cluster.summary calls the API everytime
      assert_requested(summary_stub, times: 3)
      assert_equal(cluster[:name], 'ESXiHost')
    end
  end
end
