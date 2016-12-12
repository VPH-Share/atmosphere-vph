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
        Rails.logger.debug("Attempting to authenticate with JWT")

        # TODO: Run vapor over http and use admin:admin123 to log in

        # TODO: Scrub header for JWT (read up on jwt.io - invocation standard) - implemented here as bearer_token
        #Rails.logger.debug("My request headers (old): #{request.headers.inspect}")
        Rails.logger.debug("My request headers: #{headers.inspect}")
        Rails.logger.debug("My auth header: #{request.headers['HTTP_AUTHORIZATION']}")
        Rails.logger.debug("My params: #{params.inspect}")

        Rails.logger.debug("Scrubbed token: #{@token}")

#        return fail(:invalid_token) unless jwt_token


        # TODO: Check if token is valid
        Rails.logger.debug("Checking if token is valid...")
        return fail(:invalid_token) if @token.blank? # Is a more sophisticated check required here?
        Rails.logger.debug("...success.")

        # TODO: Implement from_token in class User
        #decoded_token = JWT.decode @token, nil, true, { :algorithm => 'ES256' }
        #decoded = JWT.decode(@token, nil, false)

        decoded_token = token_data(@token)
        Rails.logger.debug("Decoded token: #{decoded_token}")

        # algorithm = 'ES256'
        # Rails.logger.debug("Setting JWT key...")
        # begin
        #   Rails.logger.debug("My key: #{Vphshare::Application.config.jwt.key}")
        #   key = Vphshare::Application.config.jwt.key
        #
        #   Rails.logger.debug("Attempting to decode token...")
        #
        #   Rails.logger.debug JWT.decode(token, key, true, algorithm: algorithm)
        #
        #   Rails.logger.debug("Decoded token: #{token_data(@token).inspect}")
        # rescue Exception => e
        #   Rails.logger.debug("Exception occurred: #{e.inspect}")
        # end


        # TODO: Create new User object if none yet exist for the given e-mail
        # TODO: In atmosphere-vph, add a class method similar to vph_find_or_create in User

        # TODO: For testing, generate a pair of JWT keys, sign/validate tokens locally

        Rails.logger.debug("Attempting to authenticate...")

        resource = Atmosphere::User.jwt_find_or_create(decoded_token.first)

        Rails.logger.debug("Have user: #{resource.inspect}")

        # TODO: Implement sudoability for JWT authenticated users
        # resource = sudo!(resource, sudo_as) if sudo_as

        # TODO: Run this here for sudo>> resource = sudo!(resource, sudo_as) if sudo_as

        Rails.logger.debug("Have user (post sudo): #{resource.inspect}")


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


#        JWT.decode(token, Application.config.jwt.key, true,
#                   algorithm: Application.config.jwt.key_algorithm)
      end
    end
  end
end

Warden::Strategies.add(:jwt, Devise::Strategies::JwtAuthenticatable)
