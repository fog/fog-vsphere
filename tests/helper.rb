begin
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
rescue LoadError => e
  $stderr.puts "not recording test coverage: #{e.inspect}"
end

require File.expand_path('../../lib/fog/vsphere', __FILE__)
