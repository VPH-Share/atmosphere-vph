module Atmosphere::DevModePropertySetExt
  extend ActiveSupport::Concern

  included do
    belongs_to :security_proxy,
      class_name: '::SecurityProxy'
  end

  module ClassMethods
    def copy_additional_params
      [ 'security_proxy_id' ]
    end
  end
end