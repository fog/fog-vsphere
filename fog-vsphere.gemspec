
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fog/vsphere/version'

Gem::Specification.new do |spec|
  spec.name          = 'fog-vsphere'
  spec.version       = Fog::Vsphere::VERSION
  spec.authors       = ['J.R. Garcia']
  spec.email         = ['jr@garciaole.com']

  spec.summary       = "Module for the 'fog' gem to support VMware vSphere."
  spec.description   = 'This library can be used as a module for `fog` or as standalone provider to use vSphere in applications.'
  spec.homepage      = 'https://github.com/fog/fog-vsphere'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(tests?|spec|features)/}) }
  spec.test_files    = spec.files.grep(%r{^tests\/})

  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_runtime_dependency 'fog-core'
  spec.add_runtime_dependency 'rbvmomi', '>= 1.9', '< 3'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'minitest', '~> 5.8'
  spec.add_development_dependency 'rubocop', '~> 0.50.0'
  spec.add_development_dependency 'mocha', '~> 1.8'
  spec.add_development_dependency 'shindo', '~> 0.3'
  spec.add_development_dependency 'webmock', '~> 3.5'
  spec.add_development_dependency 'vcr', '~> 4.0'
end
