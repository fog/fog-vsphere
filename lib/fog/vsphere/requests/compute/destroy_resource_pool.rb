module Fog
  module Vsphere
    class Compute
      class Real
        def destroy_resource_pool(attributes = {})
          get_raw_resource_pool_by_ref(attributes).Destroy_Task().wait_for_completion
        end
      end

      class Mock
        def destroy_resource_pool(attributes = {}); end
      end
    end
  end
end
