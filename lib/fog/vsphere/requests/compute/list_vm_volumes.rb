# rubocop:disable Lint/RescueWithoutErrorClass
module Fog
  module Vsphere
    class Compute
      class Real
        # [VirtualDisk(
        #  backing: VirtualDiskFlatVer2BackingInfo(
        #    contentId: "a172d19487e878e17d6b16ff2505d7eb",
        #    datastore: Datastore("datastore-162"),
        #    diskMode: "persistent",
        #    dynamicProperty: [],
        #    fileName: "[Storage1] rhel6-mfojtik/rhel6-mfojtik.vmdk",
        #    split: false,
        #    thinProvisioned: true,
        #    uuid: "6000C29c-a47d-4cd9-5249-c371de775f06",
        #    writeThrough: false
        #  ),
        #  capacityInKB: 8388608,
        #  controllerKey: 1000,
        #  deviceInfo: Description(
        #    dynamicProperty: [],
        #    label: "Hard disk 1",
        #    summary: "8,388,608 KB"
        #  ),
        #  dynamicProperty: [],
        #  key: 2001,
        #  shares: SharesInfo( dynamicProperty: [], level: "normal", shares: 1000 ),
        #  unitNumber: 1
        # )]

        def list_vm_volumes(vm_id)
          get_vm_ref(vm_id).disks.map do |vol|
            {
              id: vol.backing.uuid,
              thin: (begin
                          vol.backing.thinProvisioned
                        rescue
                          (nil)
                        end),
              eager_zero: (begin
                          vol.backing.eagerlyScrub
                        rescue
                          (nil)
                        end),
              mode: vol.backing.diskMode,
              filename: vol.backing.fileName,
              datastore: (begin
                               vol.backing.datastore.name
                             rescue
                               (nil)
                             end),
              size: vol.capacityInKB,
              name: vol.deviceInfo.label,
              key: vol.key,
              unit_number: vol.unitNumber,
              controller_key: vol.controllerKey
            }
          end
        end
      end
      class Mock
        def list_vm_volumes(vm_id); end
      end
    end
  end
end
