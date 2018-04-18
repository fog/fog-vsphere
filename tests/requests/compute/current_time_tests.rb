Shindo.tests('Fog::Compute[:vsphere] | current_time request', ['vsphere']) do
  compute = Fog::Compute[:vsphere]

  tests('The response should') do
    response = compute.current_time
    test('be a kind of Hash') { response.is_a? Hash }
    test('have a current_time key') { response.key? 'current_time' }
    test('have a current_time key with a Time value') { response['current_time'].is_a? Time }
  end
end
