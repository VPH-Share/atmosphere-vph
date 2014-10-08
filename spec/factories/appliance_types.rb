FactoryGirl.define do
  factory :appliance_type, class: 'Atmosphere::ApplianceType' do
    name { Faker::Lorem.words(10).join(' ') }
  end
end