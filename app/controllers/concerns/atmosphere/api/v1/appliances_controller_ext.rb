module Atmosphere
  module Api
    module V1
      module AppliancesControllerExt
        extend ActiveSupport::Concern

        def delegate_auth
          current_user ? current_user.mi_ticket : nil
        end
      end
    end
  end
end