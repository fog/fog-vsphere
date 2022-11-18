Shindo.tests('Fog::Compute[:vsphere] | servers collection', ['vsphere']) do
  servers = Fog::Compute[:vsphere].servers

  tests('The servers collection') do
    pending # Not mocked
    test('should not be empty') { !servers.empty? }
    tests('should be a kind of Fog::Vsphere::Compute::Servers').returns(Fog::Vsphere::Compute::Servers) { servers }
    test('should be able to reload itself') { servers.reload }
    tests('should be able to get a model') do
      tests('by managed object reference').returns(String) { servers.get('jefftest') }
      tests('by instance uuid').returns(String) { servers.get('5032c8a5-9c5e-ba7a-3804-832a03e16381') }
    end
  end
end
