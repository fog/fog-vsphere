module Fog
  module Compute
    class Vsphere
      # https://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.vm.Summary.StorageSummary.html
      class VirtualMachineStorageSummary < Fog::Model
        attribute :committed
        attribute :timestamp
        attribute :uncommitted
        attribute :unshared

      end
    end
  end
end
