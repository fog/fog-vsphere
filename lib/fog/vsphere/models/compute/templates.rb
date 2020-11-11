module Fog
  module Vsphere
    class Compute
      class Templates < Fog::Collection
        model Fog::Vsphere::Compute::Template

        def all(filters = {})
          load service.list_templates(filters)
        end

        def get(id)
          new service.get_template(id)
        end
      end
    end
  end
end
