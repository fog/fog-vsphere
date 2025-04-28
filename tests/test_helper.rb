require 'mocha/minitest'
require 'vcr'
require 'webmock/minitest'

VCR.configure do |config|
  config.cassette_library_dir = "tests/fixtures/vcr_cassettes/6_7"
  config.hook_into :webmock
  config.default_cassette_options = { match_requests_on: [:body] }
end

# Makes these parameters available to the cassettes for easier recording
module Fog
  module Vsphere
    # Allows to skip writing of shared examples.
    module VCRCasseteFilterShared
      def record_http_interaction(interaction)
        @shared_cassette ||= VCR::Cassette.new('shared', erb: TestConfig.load.to_h)
        return if @shared_cassette.http_interactions.has_interaction_matching?(interaction.request)
        interaction.request.uri = "https://<%= vsphere_server %>/sdk"
        super(interaction)
      end
    end
    ::VCR::Cassette.send(:prepend, VCRCasseteFilterShared)

    module TestHelper
      def prepare_compute
        Fog::Compute.new(TestConfig.load.to_h.merge(provider: 'vsphere'))
      end

      # Records new cassette, but before writing removes the examples already in *shared* cassette.
      def recording_webmock_cassette(name, options = {}, &block)
        WebMock::Config.instance.net_http_connect_on_start = true
        record_opts = { record: :all, erb: TestConfig.load.to_h }

        VCR.use_cassette(name, record_opts.merge(options), &block)
      ensure
        WebMock::Config.instance.net_http_connect_on_start = false
      end

      def with_webmock_cassette(name, options = {}, &block)
        VCR.use_cassette('shared', erb: TestConfig.load.to_h, allow_playback_repeats: true) do
          VCR.use_cassette(name, options.merge(erb: TestConfig.load.to_h), &block)
        end
      end
    end

    class TestConfig
      FILE = File.join(File.dirname(__FILE__), 'vsphere_config.yml')
      ATTRIBUTES = %w[server username password rev expected_pubkey_hash].freeze
      DEFAULTS = {
        vsphere_server: '127.0.0.1',
        vsphere_username: 'Administrator@example.com',
        vsphere_password: 'StrongAdminPassword'
      }.freeze

      def self.load
        @loaded ||= new(File.exist?(FILE) ? YAML.load_file(FILE) : DEFAULTS)
      end

      def initialize(config = {})
        @config = parse(config)
      end

      def to_h
        @config.dup
      end

      def parse(config, prefix = 'vsphere')
        ATTRIBUTES.each_with_object({}) do |attr_name, parsed|
          full_name = "#{prefix}_#{attr_name}"
          parsed[full_name.to_sym] = config[full_name.to_sym] || config[full_name] || config[attr_name]
        end
      end
    end
  end
end
