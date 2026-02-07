Shindo.tests('Fog::Compute[:vsphere] | destroy_iso request', ['vsphere']) do
  compute = Fog::Compute[:vsphere]

  tests('The response should') do
    response = compute.destroy_iso(
      'datacenter' => 'dc1',
      'datastore' => 'datastore-1',
      'local_path' => '/tmp/test.iso'
    )
    test('be true') { response == true }
  end

  tests('The expected options') do
    raises(ArgumentError, 'raises ArgumentError when required options are missing') { compute.destroy_iso }
  end
end
