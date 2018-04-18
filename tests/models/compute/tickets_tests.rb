Shindo.tests('Fog::Compute[:vsphere] | hosts collection', ['vsphere']) do
  service = Fog::Compute[:vsphere]
  server = service.servers.last

  tests('The tickets collection') do
    test('should create a ticket for a server') { service.tickets(server: server).create.is_a? Fog::Compute::Vsphere::Ticket }
  end
end
