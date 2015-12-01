module Fog
  module Compute
    class Vsphere
      # https://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.vm.Summary.html
      class VirtualMachineSummary < Fog::Model
        attribute :config         #VirtualMachineConfigSummary
        attribute :customValue    #CustomFieldValue[]
        attribute :guest          #VirtualMachineGuestSummary
        attribute :overallStatus  #ManagedEntityStatus
        attribute :quickStats     #VirtualMachineQuickStats
        attribute :runtime        #VirtualMachineRuntimeInfo
        attribute :storage        #VirtualMachineStorageSummary
        attribute :vm             #ManagedObjectReference to a VirtualMachine

        def initialize(attributes={})
          super
          #TODO: Other objects should get initialized here
          #TODO: For now they will be their rbvmomi equivalents by default
          self.storage = VirtualMachineStorageSummary.new(attributes[:storage].props) if attributes[:storage] && attributes[:storage].props
          self.config = VirtualMachineConfigSummary.new(attributes[:config].props) if attributes[:config] && attributes[:config].props
        end
      end
    end
  end
end
