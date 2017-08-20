Shindo.tests('Fog::Compute[:vsphere] | hosts collection', ['vsphere']) do

  servers = Fog::Compute[:vsphere].servers
  server = servers.last
  ticket = server.acquire_ticket

  tests('A ticket') do
    test('should have a ticket') { not ticket.ticket.empty? }
    test('should have a host') { not ticket.host.empty? }
    test('should have a port') { ticket.port.kind_of? Fixnum }
    test('should have a ssl ssl_thumbprint') { not ticket.ssl_thumbprint.empty? }
  end

end
