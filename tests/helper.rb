require 'minitest/autorun'
require 'mocha/minitest'
Shindo::Tests.send(:include, Mocha::API)

require File.expand_path('../../lib/fog/vsphere', __FILE__)
