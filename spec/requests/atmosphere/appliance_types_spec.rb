require 'rails_helper'

describe Atmosphere::Api::V1::ApplianceTypesController do
  include ApiHelpers

  describe 'PUT /appliance_types/:id' do
    it 'updates security proxy' do
      user = create(:user)
      at = create(:appliance_type, author: user)
      sec_proxy = create(:security_proxy, name: 'different/one')
      msg = {
        appliance_type: {
          security_proxy_id: sec_proxy.id
        }
      }

      put api("/appliance_types/#{at.id}", user), msg
      at.reload

      expect(at.security_proxy).to eq sec_proxy
    end
  end
end