# frozen_string_literal: true
require 'devise/strategies/authenticatable'
require 'jwt'

module Devise
  module Strategies
    class JwtAuthenticatable < Authenticatable
      def valid?
        super || token # Why super? Should always return false
      end

      def authenticate!
        Rails.logger.debug("Authenticating with JWT.")
        return fail(:invalid_token) if @token.blank? # Is a more sophisticated check required here?
        decoded_token = token_data(@token)
        resource = Atmosphere::User.jwt_find_or_create(decoded_token.first)
        resource ? success!(resource) : fail(:invalid_credentials)
      rescue
        fail(:invalid_credentials)
      end

      private

      def token
        @token ||= bearer_token
      end

      def bearer_token
        pattern = /^Bearer /
        header  = request.env['HTTP_AUTHORIZATION']
        header.gsub(pattern, '') if header && header.match(pattern)
      end

      def token_data(token)
        algorithm = Vphshare::Application.config.jwt.key_algorithm
        key = Vphshare::Application.config.jwt.key

        begin
          JWT.decode(token, key, true, algorithm: algorithm)
        rescue Exception => e
          Rails.logger.error("Error decoding token: #{e.message}")
        end
      end
    end
  end
end

Warden::Strategies.add(:jwt, Devise::Strategies::JwtAuthenticatable)
