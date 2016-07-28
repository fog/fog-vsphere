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
