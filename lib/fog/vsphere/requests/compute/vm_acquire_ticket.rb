module Fog
  module Vsphere
    class Compute
      class Real
        def vm_acquire_ticket(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key?('instance_uuid')
          ticket_type = options['ticket_type'] || 'webmks'

          vm_mob_ref = get_vm_ref(options['instance_uuid'])

          ticket = vm_mob_ref.AcquireTicket(ticketType: ticket_type)
          {
            'ticket' => ticket.ticket,
            'host' => ticket.host,
            'port' => ticket.port,
            'ssl_thumbprint' => ticket.sslThumbprint
          }
        end
      end

      class Mock
        def vm_acquire_ticket(options = {})
          raise ArgumentError, 'instance_uuid is a required parameter' unless options.key?('instance_uuid')
          {
            'ticket' => 'fdsfdsf',
            'host' => 'esxi.example.com',
            'port' => 443,
            'ssl_thumbprint' => '1C:63:E1:BD:56:03:EB:44:85:12:12:FC:DA:40:11:65:0E:30:A1:B8'
          }
        end
      end
    end
  end
end
