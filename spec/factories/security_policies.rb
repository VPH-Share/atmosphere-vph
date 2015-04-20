FactoryGirl.define do
  factory :security_policy do |f|
    name 'security/policy'
    payload { FFaker::Lorem.words(10).join(' ') }
  end
end