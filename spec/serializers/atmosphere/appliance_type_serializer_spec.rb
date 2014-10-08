require 'rails_helper'

describe Atmosphere::ApplianceTypeSerializer do
  it 'adds security_proxy_id to returned json' do
    sp = create(:security_proxy)
    at = create(:appliance_type, security_proxy: sp)
    serializer = Atmosphere::ApplianceTypeSerializer.new(at)

    result = JSON.parse(serializer.to_json)

    expect(result['appliance_type']['security_proxy_id']).to eq sp.id
  end
end