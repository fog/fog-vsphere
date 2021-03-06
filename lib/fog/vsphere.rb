require 'fog/core'

module Fog
  module Vsphere
    extend Fog::Provider

    module Errors
      class ServiceError < Fog::Errors::Error; end
      class SecurityError < ServiceError; end
      class NotFound < ServiceError; end
    end

    autoload :Compute, File.expand_path('../vsphere/compute', __FILE__)

    service(:compute, 'Compute')

    # This helper was originally added as Fog.class_as_string and moved to core but only used here
    def self.class_from_string(name, default_path = '')
      const = default_path.empty? ? name.to_s : "#{default_path}::#{name}"
      klass = const.split('::').inject(Object) { |m, c| m.const_get(c) }
      return klass unless klass == Object
    rescue NameError
      nil
    end
  end
end
