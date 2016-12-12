require 'rails_helper'
require 'spec_helper'
require 'jwt'

describe Devise::Strategies::JwtAuthenticatable do
  include ApiHelpers

  let!(:jwtuser) { create(:user, login: 'test_user', email: 'testuser@nowhere.pl') }

  before do

    #Decoded token: [{"name"=>"Piotr Nowakowski", "email"=>"ymnowako@cyf-kr.edu.pl", "iss"=>"EurValve Portal", "exp"=>1481303217}, {"typ"=>"JWT", "alg"=>"ES256"}]

#    ecdsa_key = OpenSSL::PKey::EC.new 'prime256v1'
#    ecdsa_key.generate_key
    ecdsa_public = OpenSSL::PKey::EC.new Vphshare::Application.config.jwt.key
    ecdsa_public.private_key = nil

    puts "ECDSA public key: #{ecdsa_public.to_pem.inspect}"

    token = JWT.encode(
      {
        name: jwtuser.login,
        email: jwtuser.email,
        iss: 'EurValve Portal',
        exp: (Time.now+24.hours).to_i
      },
      Vphshare::Application.config.jwt.key, 'ES256'
    )

    # token = JWT.encode({user: jwtuser.email},
    #                    ENV["AUTH_SECRET"], "HS256")
#    request.headers['Authorization'] = "Bearer #{token}"

#    header "Authorization", "Bearer #{token}"
    get '/api/v1/appliance_sets', nil, {'Authorization' => "Bearer #{token}"}
  end
  it 'authenticates properly with valid JWT token' do
    expect(response.status).to eq 200
  end

  # it 'responds with a 404 status' do
  #   puts "Response: #{response.inspect}"
  #
  #   expect(response.status).to eq 404
  # end

#  it 'responds with a message of Not found' do
#    message = json["errors"].first["detail"]
#    expect(message).to eq("Not found")
#  end
end
