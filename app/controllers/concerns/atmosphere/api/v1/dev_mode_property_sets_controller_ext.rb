module Atmosphere
  module Api
    module V1
      module DevModePropertySetsControllerExt
        extend ActiveSupport::Concern

        def update_params_ext
          [ :security_proxy_id ]
        end
      end
    end
  end
end