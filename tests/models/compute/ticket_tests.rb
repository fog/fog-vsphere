Shindo.tests('Fog::Compute[:vsphere] | hosts collection', ['vsphere']) do
  servers = Fog::Compute[:vsphere].servers
  server = servers.last
  ticket = server.acquire_ticket

  tests('A ticket') do
    test('should have a ticket') { !ticket.ticket.empty? }
    test('should have a host') { !ticket.host.empty? }
    test('should have a port') { ticket.port.is_a?(Integer) }
    test('should have a ssl ssl_thumbprint') { !ticket.ssl_thumbprint.empty? }
  end
end
