FactoryGirl.define do
  factory :appliance_set, class: 'Atmosphere::ApplianceSet' do |f|
    name 'AS'
    user

    trait :development do
      appliance_set_type :development
    end

    factory :dev_appliance_set, traits: [:development]
  end
end