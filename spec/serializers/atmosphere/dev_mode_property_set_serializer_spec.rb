require 'rails_helper'

describe Atmosphere::ApplianceTypeSerializer do
  it 'adds security_proxy_id into created json' do
    sp = create(:security_proxy)
    dev_mode = create(:dev_mode_property_set, security_proxy: sp)
    serializer = Atmosphere::DevModePropertySetSerializer.new(dev_mode)

    result = JSON.parse(serializer.to_json)

    expect(result['dev_mode_property_set']['security_proxy_id']).to eq sp.id
  end
end