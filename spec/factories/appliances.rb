FactoryGirl.define do
  factory :appliance, class: 'Atmosphere::Appliance' do |f|
    appliance_set
    appliance_configuration_instance
    appliance_type
    name { SecureRandom.hex(4) }
    description { SecureRandom.hex(4) }

    trait :dev_mode do
      appliance_set { create(:dev_appliance_set) }
    end

    factory :appl_dev_mode, traits: [:dev_mode]
  end
end