require 'devise/strategies/token_authenticatable'

module Atmosphere
  module Api
    module ApplicationControllerExt
      extend ActiveSupport::Concern

      included do
        before_action :set_project

        def delegate_auth
          current_user ? current_user.mi_ticket : nil
        end

        def token_request?
          mi_ticket || jwt_token || token
        end

        def pdp
          Rails.logger.debug("Matching PDP to request content...")
          # pdp = nil # TODO: use permit-nothing default pdp

          pdp = case
            when mi_request? then MiApplianceTypePdp
            when token_request? then Atmosphere::DefaultPdp
            when jwt_request? then Atmosphere::LocalPdp
            else nil # TODO: use permit-nothing default pdp
          end

          pdp
        end

        private

        def mi_request?
          mi_ticket.present?
        end

        def token_request?
          token.present?
        end

        def jwt_request?
          jwt_token.present?
        end

        def mi_ticket
          params[Air.config.mi_authentication_key] ||
            request.headers[Air.config.header_mi_authentication_key]
        end

        def jwt_token
          pattern = /^Bearer /
          header  = request.env['HTTP_AUTHORIZATION']
          header.gsub(pattern, '') if header && header.match(pattern)
        end

        def token
          params[Devise::Strategies::TokenAuthenticatable.key].presence ||
            request.headers[Devise::Strategies::TokenAuthenticatable.header_key].
              presence
        end

        def set_project
          current_user.project = project if current_user
        end

        def project
          params[Air.config.project_key] ||
            request.headers[Air.config.header_project_key]
        end

        def current_ability
          @current_ability ||= Atmosphere.ability_class.new(current_user, load_admin_abilities?, pdp)
        end

      end
    end
  end
end