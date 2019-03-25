require 'mocha/minitest'
require 'webmock/minitest'

module Fog
  module Vsphere
    module TestHelper
      def stub_request_with_files(stub_name, stubs_dir = "#{File.dirname(__FILE__)}/data/requests")
        stub_request(:post, 'https://127.0.0.1/sdk')
          .with(body: File.read("#{stubs_dir}/#{stub_name}.req").strip)
          .to_return(body: File.read("#{stubs_dir}/#{stub_name}.res").strip)
      end

      def stub_connection_requests
        stub_request_with_files('service_content')
        stub_request_with_files('login')
        stub_request_with_files('session_props')
      end

      def stub_basic_requests
        stub_connection_requests

        stub_request_with_files('root_folder_listing')
        stub_request_with_files('datacenter_listing')
        stub_request_with_files('dc_host_folder')
      end

      def prepare_compute
        stub_basic_requests
        Fog::Compute.new(
          provider: 'vsphere',
          vsphere_username: 'Administrator@example.com',
          vsphere_password: 'password',
          vsphere_server: '127.0.0.1',
          vsphere_rev: '6.7'
        )
      end
    end
  end
end
