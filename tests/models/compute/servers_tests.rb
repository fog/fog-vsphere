Shindo.tests('Fog::Compute[:vsphere] | servers collection', ['vsphere']) do
  servers = Fog::Compute[:vsphere].servers

  tests('The servers collection') do
    test('should not be empty') { !servers.empty? }
    test('should be a kind of Fog::Compute::Vsphere::Servers') { servers.is_a? Fog::Compute::Vsphere::Servers }
    tests('should be able to reload itself').succeeds { servers.reload }
    tests('should be able to get a model') do
      tests('by managed object reference').succeeds { servers.get 'jefftest' }
      tests('by instance uuid').succeeds { servers.get '5032c8a5-9c5e-ba7a-3804-832a03e16381' }
    end
  end
end
