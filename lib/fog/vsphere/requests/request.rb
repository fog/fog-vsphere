module Fog
  module Vsphere
    module Requests
      class Request
        attr_accessor :connection

        def initialize(connection)
          @connection = connection
        end

        def run
          raise Fog::Errors::NotImplemented, "The commands #{self.class.name}#run method is not implemented."
        end
      end
    end
  end
end
