require 'rails_helper'
require 'spec_helper'
require 'jwt'

describe Devise::Strategies::JwtAuthenticatable do
  include ApiHelpers

  let!(:jwtuser) { create(:user, login: 'test_user', email: 'testuser@nowhere.pl') }

  before do
    ecdsa_public = OpenSSL::PKey::EC.new Vphshare::Application.config.jwt.keys.first
    ecdsa_public.private_key = nil

    unknown_key = OpenSSL::PKey::EC.new 'prime256v1'
    unknown_key.generate_key

    @valid_token = JWT.encode(
      {
        name: jwtuser.login,
        email: jwtuser.email,
        iss: 'EurValve Portal',
        exp: (Time.now+24.hours).to_i
      },
      Vphshare::Application.config.jwt.keys.first, 'ES256'
    )

    @valid_token_other_key = JWT.encode(
        {
            name: jwtuser.login,
            email: jwtuser.email,
            iss: 'EurValve Portal',
            exp: (Time.now+24.hours).to_i
        },
        Vphshare::Application.config.jwt.keys.second, 'ES256'
    )

    @token_unknown_key = JWT.encode(
        {
            name: jwtuser.login,
            email: jwtuser.email,
            iss: 'EurValve Portal',
            exp: (Time.now+24.hours).to_i
        },
        OpenSSL::PKey::EC.new(unknown_key.to_pem), 'ES256'
    )

    @valid_token_new_user = JWT.encode(
        {
            name: 'foo',
            email: 'foo@nowhere.edu',
            iss: 'EurValve Portal',
            exp: (Time.now+24.hours).to_i
        },
        Vphshare::Application.config.jwt.keys.first, 'ES256'
    )

    @expired_token = JWT.encode(
        {
            name: jwtuser.login,
            email: jwtuser.email,
            iss: 'EurValve Portal',
            exp: (Time.now-1.hours).to_i
        },
        Vphshare::Application.config.jwt.keys.first, 'ES256'
    )
  end
  it 'authenticates properly with valid JWT token' do
    get '/api/v1/appliance_sets', nil, {'Authorization' => "Bearer #{@valid_token}"}
    expect(response.status).to eq 200
  end
  it 'authenticates properly with valid JWT token using alternative key' do
    get '/api/v1/appliance_sets', nil, {'Authorization' => "Bearer #{@valid_token_other_key}"}
    expect(response.status).to eq 200
  end
  it 'denies access when using unknown key' do
    get '/api/v1/appliance_sets', nil, {'Authorization' => "Bearer #{@token_unknown_key}"}
    expect(response.status).to eq 401
  end
  it 'denies access with expired token' do
    get '/api/v1/appliance_sets', nil, {'Authorization' => "Bearer #{@expired_token}"}
    expect(response.status).to eq 401
  end
  it 'authorizes known user without creating a new User object' do
    expect(Atmosphere::User.count).to eq 1
    get '/api/v1/appliance_sets', nil, {'Authorization' => "Bearer #{@valid_token}"}
    expect(Atmosphere::User.count).to eq 1
  end
  it 'creates User object for previously unknown user' do
    expect(Atmosphere::User.count).to eq 1
    get '/api/v1/appliance_sets', nil, {'Authorization' => "Bearer #{@valid_token_new_user}"}
    expect(Atmosphere::User.count).to eq 2
  end

  # this checks whether the proper PDP is used to validate requests which contain JWT tokens
  context 'starting appliances' do
    let!(:portal_set) do
      create(:appliance_set, user: jwtuser, appliance_set_type: :portal)
    end
    let!(:development_set) do
      create(:appliance_set, user: jwtuser, appliance_set_type: :development)
    end

    let!(:fund) { create(:fund) }

    let!(:public_at) { create(:appliance_type, visible_to: :all) }

    let(:static_config) do
      create(:static_config_template, appliance_type: public_at)
    end
    let(:static_request_body) { start_request(static_config, portal_set) }

    let(:development_set) do
      create(:appliance_set, user: jwtuser, appliance_set_type: :development)
    end

    let(:static_dev_request_body) do
      {
        appliance: {
          configuration_template_id: static_config.id,
          appliance_set_id: development_set.id,
          fund_id: fund.id
        }
      }
    end

    it 'uses correct PDP to disallow starting appliance' do
      expect_any_instance_of(Atmosphere::LocalPdp).to receive(:can_start_in_production?).and_return(false)
      post '/api/v1/appliances', headers: {'Authorization' => "Bearer #{@valid_token}"}, params: static_request_body
    end
  end

  def start_request(at_config, appliance_set)
    generic_start_request(at_config, appliance_set,
                          name: 'my_name', description: 'my_description')
  end

  def generic_start_request(at_config, appliance_set, options = {})
    {
        appliance: {
            configuration_template_id: at_config.id,
            appliance_set_id: appliance_set.id,
            name: options[:name],
            description: options[:description]
        }
    }
  end
end
