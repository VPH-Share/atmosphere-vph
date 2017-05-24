require 'rails_helper'

describe Atmosphere::Api::V1::AppliancesController do
  include ApiHelpers

  context 'with mi_ticket parameter' do
    let(:user)  { create(:user) }
    let!(:portal_set) { create(:appliance_set, user: user, appliance_set_type: :portal)}
    let!(:public_at) { create(:appliance_type, visible_to: :all) }
    let(:config_with_mi_ticket) do
      create(:appliance_configuration_template,
        appliance_type: public_at,
        payload: 'dynamic config with mi_ticket: #{' +
          "#{Air.config.mi_authentication_key}}")
    end

    let(:dynamic_request_with_mi_ticket_body) do
      {
        appliance: {
          configuration_template_id: config_with_mi_ticket.id,
          appliance_set_id: portal_set.id,
          params: {
            param1: 'a',
            param2: 'b',
            param3: 'c'
          }
        }
      }
    end

    before do
      adaptor = double
      allow(::OmniAuth::Vph::Adaptor).to receive(:new).and_return(adaptor)
      mi_user_info = { "mi" => "user details" }
      allow(adaptor).to receive(:user_info).with('ticket').and_return(mi_user_info)
      allow(adaptor).to receive(:map_user).with(mi_user_info).and_return({
          'email' => user.email,
          'login' => user.login,
          'full_name' => user.full_name,
          'roles' => user.roles.to_a
        })
    end

    it 'creates dynamic configuration with header mi ticket injected' do
      allow_any_instance_of(MiApplianceTypePdp).to receive(:can_start_in_production?).and_return(true)
      post api("/appliances"), params: dynamic_request_with_mi_ticket_body,
           headers: {"MI-TICKET" => 'ticket'}
      config_instance = Atmosphere::ApplianceConfigurationInstance.find(appliance_response['appliance_configuration_instance_id'])
      expect(config_instance.payload).to eq 'dynamic config with mi_ticket: ticket'
    end

    it 'creates dynamic configuration with query param mi ticket injected' do
      allow_any_instance_of(MiApplianceTypePdp).to receive(:can_start_in_production?).and_return(true)
      post api("/appliances?mi_ticket=ticket"), params: dynamic_request_with_mi_ticket_body
      config_instance = Atmosphere::ApplianceConfigurationInstance.find(appliance_response['appliance_configuration_instance_id'])
      expect(config_instance.payload).to eq 'dynamic config with mi_ticket: ticket'
    end
  end

  def appliance_response
    json_response['appliance']
  end
end