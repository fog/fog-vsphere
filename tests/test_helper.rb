require 'mocha/minitest'
require 'vcr'
require 'webmock/minitest'

# WebMock::Config.instance.net_http_connect_on_start = true

VCR.configure do |config|
  config.cassette_library_dir = "tests/fixtures/vcr_cassettes/6_7"
  config.hook_into :webmock
  config.default_cassette_options = { match_requests_on: [:body] }
end

# Makes these parameters available to the cassettes for easier recording
SHARED_VSPHERE_PARAMS = {
  vsphere_server: '127.0.0.1',
  vsphere_username: 'Administrator@example.com',
  vsphere_password: 'StrongAdminPassword'
}.freeze

# Allows to skip writing of shared examples.
module VCRCasseteFilterShared
  def record_http_interaction(interaction)
    @shared_cassette ||= VCR::Cassette.new('shared', erb: SHARED_VSPHERE_PARAMS)
    return if @shared_cassette.http_interactions.has_interaction_matching?(interaction.request)
    interaction.request.uri = "https://<%= vsphere_server %>/sdk"
    super(interaction)
  end
end
VCR::Cassette.send(:prepend, VCRCasseteFilterShared)

module Fog
  module Vsphere
    module TestHelper
      def prepare_compute
        Fog::Compute.new(
          SHARED_VSPHERE_PARAMS.merge(
            provider: 'vsphere',
            vsphere_rev: '6.7'
          )
        )
      end

      # Records new cassette, but before writing removes the examples already in *shared* cassette.
      def recording_webmock_cassette(name, options = {}, &block)
        VCR.use_cassette(name, options, &block)
      end

      def with_webmock_cassette(name, options = {}, &block)
        VCR.use_cassette('shared', erb: SHARED_VSPHERE_PARAMS, allow_playback_repeats: true) do
          VCR.use_cassette(name, options.merge(erb: SHARED_VSPHERE_PARAMS), &block)
        end
      end
    end
  end
end
