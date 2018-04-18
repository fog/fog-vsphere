Shindo.tests('Fog::Compute[:vsphere] | cluster collection', ['vsphere']) do
  compute = Fog::Compute[:vsphere]

  tests('Cluster collection') do
    clusters = compute.datacenters.first.clusters

    test('should not be empty') { !clusters.empty? }
    test('should be a kind of Fog::Compute::Vsphere::Clusters') { clusters.is_a? Fog::Compute::Vsphere::Clusters }
    test('should get a cluster') { clusters.get('Solutionscluster').id == '1d4d9a3f-e4e8-4c40-b7fc-263850068fa4' }
  end

  tests('A cluster should') do
    cluster = compute.datacenters.first.clusters.get('Solutionscluster')

    test('have datastores') { cluster.datastores.first.is_a? Fog::Compute::Vsphere::Datastore }
    test('have networks') { cluster.networks.first.is_a? Fog::Compute::Vsphere::Network }
  end
end
