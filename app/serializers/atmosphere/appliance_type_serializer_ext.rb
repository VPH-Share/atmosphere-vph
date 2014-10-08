module Atmosphere::ApplianceTypeSerializerExt
  extend ActiveSupport::Concern

  included do
    has_one :security_proxy
  end
end