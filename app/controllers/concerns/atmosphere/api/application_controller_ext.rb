require 'devise/strategies/token_authenticatable'

module Atmosphere
  module Api
    module ApplicationControllerExt
      extend ActiveSupport::Concern

      def delegate_auth
        current_user ? current_user.mi_ticket : nil
      end

      def token_request?
        mi_ticket || token
      end

      private

      def mi_ticket
        params[Air.config.mi_authentication_key] ||
          request.headers[Air.config.header_mi_authentication_key]
      end

      def token
        params[Devise::Strategies::TokenAuthenticatable.key].presence ||
          request.headers[Devise::Strategies::TokenAuthenticatable.header_key].
            presence
      end
    end
  end
end