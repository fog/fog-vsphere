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
