require 'rails_helper'

describe Atmosphere::DevModePropertySet do
  it { should belong_to :security_proxy }

  context '#create_from' do
    it 'copying appliance_type attributes values' do
      sp = create(:security_proxy)
      appliance_type = create(:appliance_type, security_proxy: sp)

      target = Atmosphere::DevModePropertySet.create_from(appliance_type)

      expect(target.security_proxy).to eq appliance_type.security_proxy
    end
  end
end