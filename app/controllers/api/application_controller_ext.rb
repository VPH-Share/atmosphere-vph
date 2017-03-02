module Atmosphere::Api::ApplicationControllerExt
  extend ActiveSupport::Concern

  included do

    def pdp
      Rails.logger.debug("Using pdp() from ApplicationControllerExt")

      Rails.logger.debug("Matching PDP to request content...")
      pdp = nil # Use permit-nothing default pdp

      if
      (
        params[Air.config.mi_authentication_key] ||
            request.headers[Air.config.header_mi_authentication_key]
      )
        Rails.logger.debug("MI ticket detected; using MI PDP")
        pdp = Atmosphere::MiApplianceTypePdp
      elsif
      (
        request.env['HTTP_AUTHORIZATION'] && request.env['HTTP_AUTHORIZATION'].match(/^Bearer /)
      )
        Rails.logger.debug("JWT token detected; using local PDP")
        pdp = Atmosphere::LocalPdp
      else
        # TODO: Add a permit-nothing class to handle malformed requests gracefully.
      end

      pdp
    end

    private

    def current_ability
      Rails.logger.debug("!!!using EXTENDED current ability!!!")
      @current_ability ||= Atmosphere.ability_class.new(current_user, load_admin_abilities?, pdp)
    end
  end

end