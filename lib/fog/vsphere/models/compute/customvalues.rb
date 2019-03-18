module Fog
  module Vsphere
    class Compute
      class Customvalues < Fog::Collection
        autoload :Customvalue, File.expand_path('../customvalue', __FILE__)

        model Fog::Vsphere::Compute::Customvalue

        attr_accessor :vm

        def all(_filters = {})
          requires :vm
          case vm
          when Fog::Vsphere::Compute::Server
            load service.list_vm_customvalues(vm.id)
          else
            raise 'customvalues should have vm'
          end
        end

        def get(key)
          requires :vm
          case vm
          when Fog::Vsphere::Compute::Server
            load service.list_vm_customvalues(vm.id)
          else
            raise 'customvalues should have vm'
          end.find { |cv| cv.key == key }
        end
     end
    end
  end
end
