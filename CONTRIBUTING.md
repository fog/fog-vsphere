# Getting Involved

:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

New contributors are always welcome, when it doubt please ask questions.
We strive to be an open and welcoming community. Please be nice to one another.

## Non-Coding

- Offer feedback on open [issues](https://github.com/fog/fog-vsphere/issues).
- Organize or volunteer at events.

## Coding

- Pick a task:
- Review open [issues](https://github.com/fog/fog-vsphere/issues) for things to help on.
- [Create an issue](https://github.com/fog/fog-vsphere/issues/new) to start a discussion on additions or features.
- Fork the project, add your changes and tests to cover them in a topic branch.
- Commit your changes and rebase against `fog/fog-vsphere` to ensure everything is up to date.
- [Submit a pull request](https://github.com/fog/fog-vsphere/compare/)

### Testing

We are in a process of a covering the functionality by integrational tests.
We would like to cover all the requests made towards the vSphere instance.
Doing so should give us more confidence and make the development easier.
We will appreciate if you are able to help. Following steps will guide you
through a process of covering new/changed funcionality.

1. First of all you will need vSphere instance.
2. You need to add your vSphere instance login info in `tests/vsphere_config.yml` file.
```yaml
server: example.com
username: '<UserName>'
password: '<password>'
rev: '6.7' # optional revision of the vsphere
expected_pubkey_hash: <expected_pubkey_hash>
```
*This file is gitignored to ensure you won't accidently commit it.*
*We are making sure, that the login request is not recorded, but you may want to reasure it in a newly written cassette.*

3. write your test like this:
```ruby
# tests/requests/compute/<your_request>
it 'parses the mocked request' do
  recording_webmock_cassette('unique_mocked_request') do
    #stuff I want to get tested
  end
end
```
*But be aware, we do not mock the names of your datacenters and/or clusters, please be aware, you will need to take care not to commit any private server names/IP addresses.*

4. Run the test
5. Change the `recording_webmock_cassette` to a `with_webmock_cassette`
6. Commit, open a PR :tada:
