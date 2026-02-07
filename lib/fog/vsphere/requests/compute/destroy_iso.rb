module Fog
  module Vsphere
    class Compute
      class Real
        def destroy_iso(options = {})
          # Keep using the same validation helper for required keys, etc.
          options = destroy_iso_check_options(options)

          datastore  = get_raw_datastore(options['datastore'], options['datacenter'])
          datacenter = get_raw_datacenter(options['datacenter'])

          filename   = options['filename'] || File.basename(options['local_path'])
          remote_rel = File.join(options['upload_directory'].to_s, filename).sub(%r{\A/+}, '')
          remote_ds  = "[#{options['datastore']}] #{remote_rel}"

          task = connection.serviceContent.fileManager.DeleteDatastoreFile_Task(
            name: remote_ds,
            datacenter: datacenter
          )
          task.wait_for_completion

          # Return true if it is gone
          !datastore.exists?(remote_rel)
        end

        private

        def destroy_iso_check_options(options)
          default_options = {
            'upload_directory' => 'isos'
          }
          options = default_options.merge(options)
          required_options = %w[datacenter datastore local_path]
          required_options.each do |param|
            raise ArgumentError, "#{required_options.join(', ')} are required" unless options.key? param
          end
          raise Fog::Vsphere::Compute::NotFound, "Datacenter #{options['datacenter']} doesn't exist!" unless get_datacenter(options['datacenter'])
          raise Fog::Vsphere::Compute::NotFound, "Datastore #{options['datastore']} doesn't exist!" unless get_raw_datastore(options['datastore'], options['datacenter'])
          options
        end
      end

      class Mock
        def destroy_iso(options = {})
          destroy_iso_check_options(options)
          true
        end

        private

        def destroy_iso_check_options(options)
          default_options = {
            'upload_directory' => 'isos'
          }
          options = default_options.merge(options)
          required_options = %w[datacenter datastore local_path]
          required_options.each do |param|
            raise ArgumentError, "#{required_options.join(', ')} are required" unless options.key? param
          end
          options
        end
      end
    end
  end
end
