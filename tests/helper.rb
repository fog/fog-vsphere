require 'simplecov'
SimpleCov.start

require 'mocha/api'
Shindo::Tests.send(:include, Mocha::API)

require 'minitest/autorun'
require 'mocha/minitest'

require File.expand_path('../../lib/fog/vsphere', __FILE__)
