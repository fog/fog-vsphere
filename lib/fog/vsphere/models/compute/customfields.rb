module Fog
  module Vsphere
    class Compute
      class Customfields < Fog::Collection
        autoload :Customfield, File.expand_path('../customfield', __FILE__)

        model Fog::Vsphere::Compute::Customfield

        attr_accessor :vm

        def all(_filters = {})
          load service.list_customfields
        end

        def get(key)
          load(service.list_customfields).find do |cv|
            cv.key == (key.is_a? String ? key.to_i : key)
          end
        end
     end
    end
  end
end
