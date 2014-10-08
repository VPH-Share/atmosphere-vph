FactoryGirl.define do
  factory :appliance_configuration_template,
    class: 'Atmosphere::ApplianceConfigurationTemplate' do |f|
    name { Faker::Lorem.words(10).join(' ') }
    appliance_type
  end
end