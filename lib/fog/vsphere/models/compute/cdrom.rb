module Fog
  module Vsphere
    class Compute
      class Cdrom < Fog::Model
        identity :key

        attribute :filename
        attribute :name, default: 'CD-/DVD-ROM Drive'
        attribute :controller_key
        attribute :unit_number
        attribute :start_connected
        attribute :allow_guest_control
        attribute :connected

        has_one_identity :server, :servers, aliases: :instance_uuid

        def to_s
          name
        end

        def destroy
          requires :instance_uuid, :key, :unit_number

          service.destroy_vm_cdrom(self)
          true
        end

        def save
          requires :instance_uuid

          if unit_number.nil?
            used_unit_numbers = server.cdroms.map(&:unit_number)
            max_unit_number = used_unit_numbers.max

            self.unit_number = if max_unit_number > server.cdroms.size
                                 # If the max ID exceeds the number of cdroms, there must be a hole in the range. Find a hole and use it.
                                 max_unit_number.times.to_a.find { |i| used_unit_numbers.exclude?(i) }
                               else
                                 max_unit_number + 1
                               end
          else
            if server.cdroms.any? { |cdrom| cdrom.unit_number == unit_number && cdrom.id != id }
              raise "A cdrom already exists with that unit_number, so we can't save the new cdrom"
            end
          end

          data = service.add_vm_cdrom(self)

          if data['task_state'] == 'success'
            # We have to query vSphere to get the cdrom attributes since the task handle doesn't include that info.
            created = server.cdroms.get(unit_number)

            self.key = created.key
            self.filename = created.filename
            self.unit_number = created.unit_number

            true
          else
            false
          end
        end
      end
    end
  end
end
