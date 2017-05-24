require 'devise/strategies/base'
require 'omniauth-vph'
require 'devise/strategies/sudoable'

module Devise
  module Strategies
    # Strategy for signing in a user, based on a MI authenticatable token.
    # This works for both params and http. For the former, all you need to
    # do is to pass the params in the URL:
    #
    #   http://myapp.example.com/?mi_ticket=MI_TOKEN
    #   http://myapp.example.com Header: MI_TOKEN: MI_TOKEN
    class MiTokenAuthenticatable < Authenticatable
      def valid?
        super || mi_ticket
      end

      def authenticate!
        return fail(:invalid_ticket) unless mi_ticket
        begin
          mi_user_info = user_info(mi_ticket)
          return fail!(:invalid_credentials) if !mi_user_info

          auth = adaptor.map_user(mi_user_info)
          return fail(:invalid_mi_ticket) unless auth

          resource = mapping.to.vph_find_or_create(
              ::OmniAuth::AuthHash.new({info: auth}))

          return fail(:invalid_mi_ticket) unless resource
          resource.mi_ticket = mi_ticket
          success!(resource)
        rescue Exception => e
          return fail(:master_interface_error)
        end
      end

      def self.clean_cache!
        @cache && @cache.select! { |_, v| v.valid? }
      end

      private

      def adaptor
        @adaptor ||= ::OmniAuth::Vph::Adaptor.new({
            host: Air.config.vph.host,
            roles_map: Air.config.vph.roles_map,
            ssl_verify: Air.config.vph.ssl_verify
          })
      end

      def user_info(mi_ticket)
        Rails.cache.fetch(mi_ticket,  expires_in: 5.minutes) do
          adaptor.user_info(mi_ticket)
        end
      end

      def mi_ticket
        params[Air.config.mi_authentication_key] ||
          request.headers[Air.config.header_mi_authentication_key]
      end
    end
  end
end
