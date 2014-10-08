class SecurityProxy < ActiveRecord::Base
  include OwnedPayloable

  has_many :appliance_types,
    class_name: 'Atmosphere::ApplianceType'

  has_many :dev_mode_property_sets,
    dependent: :nullify,
    class_name: 'Atmosphere::DevModePropertySet'
end
