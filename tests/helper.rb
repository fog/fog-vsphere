if ENV['COVERAGE'] == 'true'
  require 'coveralls'
  require 'simplecov'
  SimpleCov.command_name "shindo:#{Process.pid.to_s}"
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.merge_timeout 3600

  Coveralls.wear!
end

require File.expand_path('../../lib/fog/vsphere', __FILE__)
