require 'ostruct'

Shindo.tests('Fog::Compute[:vsphere] | update_vm request', 'vsphere') do
  compute = Fog::Compute[:vsphere]
  server = Fog::Compute::Vsphere::Server.new

  tests('UPDATE vm | The return value should') do
    response = compute.update_vm(server)
    test('be a kind of Hash') { response.is_a? Hash }
    test('should have a task_state key') { response.key? 'task_state' }
    test('be a kind of Hash') { response.is_a? Hash }
  end
end
