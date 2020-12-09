## v3.5.0
* Clone vm from different datacenter (#263)
* Fix autoload issues (#267)
* Add extra_config attribute to server (#268)
* Expose `_ref` from Compute::Network (#265)

## v3.4.0
* list_resource_pools returns incorrect resource pool name (#256)
* Add ability to create update and delete Resource Pools (#253)
* Check datastore for existence prior vm_clone

## v3.3.1
Fixes eager zero flag (#251, #252)

## v3.3.0
* Add support for nsx-t (#248)

## v3.2.5
* Check cluster existance properly (#239)

## ~~v3.2.3~~
* Check cluster existance (#239)

## v3.2.2
* Load simple clusters (#237)
* ISO upload: correctly check if upload directory exists

## v3.2.1

* Fix VM creation on storagePod (#234)

## v3.2.0

* Annotation Notes are not set in Image based builds (#218)
* Cloning disks thin relocation and storagePod location (#216)
* Grab DC if within a folder (#214)

## v3.1.1

* Fixes multiple storagePods deployment (#213)

## v3.1.0

* Adds vcr webmock testing basics (#208)
* Allow changes for HotAdd memory and CPU (#207)
* Fix NoMethodError `blank?` without Rails (#206)
* Fix VM interfaces updates (#205)
* Network lookup by ID (#204)
* Allow add disk on storageClusters on VM clone (#202)
* Make `boot_order` an attribute of VM (#194)

## v3.0.0

* Change module namespace to Fog::Vsphere::Compute (#192)
* Update ruby string method to prevent traceback (#189)
* Allow builds with rbvmomi 2.0.0+ (#187)
* Raise error in case path and cluster do not exist (#183)
* Update vm_clone template to not always be false (#180)
* fetch datacenter by vm_mob_ref.path if user does not have permission to access hosts (#176)

## v2.5.0

* Expose extraConfig from user_data for vm_clone #172
* Support getting folder types other than vm folder #171
* Vm_clone: ERROR if options['volumes'] is not specified #170
* Patch attribute[:datacenter] for create interface #167
* Add required datacenter param to all calls which may use get_vm_interface #165
* Add option to relocate vm's datastore #164
* Add cpu_hz attribute to host (#162)
* Fix adding 8th volume to vm (#146)

## v2.4.0

* improve folder loading performance (#158)
* improve storage pod loading performance (#160)
* improve datastore loading performance (#159)
* prevent hard fail on undefined legacy networks (#157)
* add support to create vms on NSX-T networks (#153)
* set the server for fog volume objects (#152)
* add server guard to unit_number calculation (#152)

## v2.3.0

* set volume unit_number when cloning a vm (#151)
* add unclustered esxi hosts back to cluster selection (#149)
* reduce the time required to list networks (#145)

## v2.2.0

* vm interface updating needs a datacenter as option (#140)
* improve vm saving to use a single api call and support network changes (#142)

## v2.1.1

* fixes an issue where networks of type DVPort cannot be listed (#137)

## v2.1.0

* fixes two issues that broke vm cloning (#134, #135)
* performance of host listing was improved (#131)
* networks have a vlan property (#129)

## v2.0.1

* Ensure views are destroyed after use (#122)
* rescue nil for retrieving vm.config.instanceUuid (#123)

## v2.0.0

* Drop support for ruby versions < 2.0.0
* Fix regex issue when folder contains the datacenter name (#120)
* add more attributes to host model (#119)
* Fixes listing resource pools for clusters nested in folders (#118)
* Add requests to host (#116)
* Fix interface code in VM clone (#115)

## v1.13.1

* Fix typo of local variable name in clone operation (#114)

## v1.13.0

* Add ability to change boot order on VM clone (#110)
* Support cloning volumes in different datastore (#107)
* Add ability to generate new mac addresses on VM clone (#109)
* Fix list_compute_resources error when folder nested inside datacenter level (#100)
* Updated list_clusters to have an optional param or allow filtering on datacenter (#102)
* Add check option for vm_migrate
* Add vm_relocate request

## v1.12.0

* Add existing state validation for power on/off requests
* Add ability for server to acquire WebMKS ticket

## v1.11.3

* Fix issue when cloning and interface is in boot order
* Add connected attribute to interface

## v1.11.2

* Prevent failing when cloning from template to different cluster

## v1.11.1

* Use key to identify dvPort Group

## v1.11.0

* Add ability to query subresource pools
* Fix `snapshots.get(id)` when no snapshot is found
* Add `vm_remove_snapshot` request, use in `snapshot.destroy`
* Fix `snapshots.get` for non-root snapshot
* Add `vm_revert_snapshot` request and `revert` method to `snapshot`

## v1.10.0

* Add request to rename VM

## v1.9.2

* Properly escape regex characters in DC names for `list_clusters`

## v1.9.1

* Ensure connection has not been closed before using

## v1.9.0

* Add :connectable option to `update_vm_interface`
* Add ability to detach volume from VM

## v1.8.0

* Add `suspend` to server model
* Add `vm_suspend` to compute request

## v1.7.1

* Send all options to VM migrate request
* Fix VM clone with resource pool
* Remove obsolete index argument to create_disk call
* Fix error when creating volume using the wrong key name

## v1.7.0

* Update volumes when `save` is called on Server
* Add the ability to update the size of attached virtual disks
* Improve mocks for folders and networks

## v1.6.0

*  Support updating of server CPUs and memory

## v1.5.2

* Handle vSphere VMs being created or removed when searching for VM

## v1.5.1

* Move volume key generation to volume model
* Set defaults more reliably for SCSI

## v1.5.0

* Rename the get_spec method in create_rule to get_group_spec
* Change modify_vm_controller to follow changes made to create_controller

## v1.4.0

* Add ability for VMs to have multiple SCSI controllers

## v1.3.0

* Add the add_vm_controller method

## v1.2.2

* Upgrade rbvmomi depenency to latest stable series (1.9.x)

## v1.2.1

* Do not fail on 'undefined method' when nicSettingMap not present

## v1.2.0

* Add functionality for creating, listing, and destroying groups

## v1.1.0

* Add ability to list ClusterVmHostRuleInfo type rules

## v1.0.1 8/23/2016

* Update fog-vsphere.gemspec to pin RbVmomi for Ruby 1.8.x versions

## v1.0.0 7/28/2016

* No changes, just releasing v1.0.0

## v0.8.1 7/28/2016

* Fixed bug with errant hash access for customspec

## v0.8.0 6/15/2016

* List hosts in a cluster
* Deploy VM on a specific cluster
* Add cluster storage and network filter

## v0.7.0 5/16/2016

* Optionally process runcmd when creating customspec from cloudinit

## v0.6.4 4/20/2016

* Allow 'extraConfig' options when cloning VMs

## v0.6.3 3/7/2016

* Fix 'tools_installed?' modification

## v0.6.2 3/7/2016

* Return tools_installed? correctly
* Expose numCoresPerSocket in vm_clone

## v0.6.1 3/4/2016

* Refactor storage pod handling

##  v0.6.0 1/28/2016

* Improvements to upload_iso method
* Minor refactoring of unnecessarily complex code

## v0.5.0 1/18/2016

* Fix wrong string assignment in storage pods
* Pass what we know about the VM from the folder to VM creation
* Improve performance of recursive get_vm_by_name
* Ensure folder.vms only searches the VMs in that folder
* Add recursive parameter to folder.vms to search recursively

## v0.4.0 12/15/2015

* Fix cannot create vm on "Resources" resource pool
* Fix Fog::Mock.reset
* Implement support for DRS rules
* Fix issues with boot options
* Add boot retry support
* Add support for annotation and extra_config

## v0.3.0 12/3/2015

* Fix update_vm_interface
* Add add folder.destroy
* Implement CD-ROM options
* Implement storage pods
* Fix nil error when snapshots is called on a VM without snapshots
* No longer support Ruby 1.8
* Allow setting of boot order when using api > 5.0
* Select the most recent API version instead of 4.1
