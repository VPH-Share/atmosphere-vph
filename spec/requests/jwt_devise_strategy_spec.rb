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
end
