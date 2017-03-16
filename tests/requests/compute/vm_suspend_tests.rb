Shindo.tests('Fog::Compute[:vsphere] | vm_suspend request', ['vsphere']) do
  compute = Fog::Compute[:vsphere]
  powered_on_vm = '5032c8a5-9c5e-ba7a-3804-832a03e16381'

  tests('The response should') do
    response = compute.vm_suspend('instance_uuid' => powered_on_vm)
    test('be a kind of Hash') { response.is_a?(Hash) }
    test('should have a task_state key') { response.key? 'task_state' }
    test('should have a suspend_type key') { response.key? 'suspend_type' }
  end

  # When forcing the shutdown, we expect the result to be
  { true => 'suspend', false => 'standby_guest' }.each do |force, expected|
    tests("When 'force' => #{force}") do
      response = compute.vm_suspend('instance_uuid' => powered_on_vm, 'force' => force)
      test('should return suspend_type of #{expected}') { response['suspend_type'] == expected }
    end
  end

  tests('The expected options') do
    raises(ArgumentError, 'raises ArgumentError when instance_uuid option is missing') { compute.vm_suspend }
  end
end
