module Fog
  module Compute
    class Vsphere
      # https://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.vm.Summary.ConfigSummary.html
      class VirtualMachineConfigSummary < Fog::Model
        attribute :annotation
        attribute :cpuReservation
        attribute :dynamicProperty
        attribute :ftInfo #FaultToleranceConfigInfo
        attribute :guestFullName
        attribute :guestId
        attribute :installBootRequired
        attribute :instanceUuid
        attribute :memoryReservation
        attribute :memorySizeMB
        attribute :name
        attribute :numCpu
        attribute :numEthernetCards
        attribute :numVirtualDisks
        attribute :product #VAppProductInfo
        attribute :template
        attribute :uuid
        attribute :vmPathName

        def initialize(attributes={})
          super
          #TODO: Other objects get initialized here
          #TODO: For now they will be their rbvmomi counterparts
          #TODO: self.ftInfo = FaultToleranceConfigInfo.new(attributes[:ftInfo].props) if attributes[:ftInfo] && attributes[:ftInfo].props
          #TODO: self.product = VAppProductInfo.new(attributes[:product].props) if attributes[:product] && attributes[:product].props
        end
      end
    end
  end
end
