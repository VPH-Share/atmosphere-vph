# frozen_string_literal: true
require 'devise/strategies/authenticatable'
require 'jwt'

module Devise
  module Strategies
    class JwtAuthenticatable < Authenticatable
      def valid?
        token
      end

      def authenticate!
        Rails.logger.debug("Authenticating with JWT.")
        return fail(:invalid_token) if token.blank?
        decoded_token = token_data(token)
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
        keys = Vphshare::Application.config.jwt.keys

        keys.each do |key|
          decoded_token = nil
          begin
            decoded_token = JWT.decode(token, key, true, algorithm: algorithm)
          rescue Exception => e
            Rails.logger.warn("Error decoding token: #{e.message}. Trying next key...")
            next
          ensure
            Rails.logger.debug("Finished token decoding attempt with key #{key.to_s}")
          end
          if decoded_token
            Rails.logger.debug("Token decoded successfully.")
            return decoded_token
          else
            Rails.lgger.warn("Unable to decode token - no matching keys available.")
          end
        end
      end
    end
  end
end

Warden::Strategies.add(:jwt, Devise::Strategies::JwtAuthenticatable)
