require 'rails_helper'

describe Atmosphere::Api::V1::AppliancesController do
  include ApiHelpers

  describe 'PUT /dev_mode_property_sets/:id' do
    it 'updates security proxy' do
      developer = create(:developer)
      as = create(:dev_appliance_set, user: developer)
      appl = create(:appliance, appliance_set: as)
      sec_proxy = create(:security_proxy)
      update_params = {
        dev_mode_property_set: {
          security_proxy_id: sec_proxy.id
        }
      }

      put api("/dev_mode_property_sets/#{appl.dev_mode_property_set.id}",
                developer), update_params
      appl.reload

      expect(response.status).to eq 200
      expect(appl.dev_mode_property_set.security_proxy).to eq sec_proxy
    end
  end
end