module Fog
  module Vsphere
    class Compute
      class Real
        def current_time
          current_time = connection.serviceInstance.CurrentTime
          { 'current_time' => current_time }
        end
      end

      class Mock
        def current_time
          { 'current_time' => Time.now.utc }
        end
      end
    end
  end
end
