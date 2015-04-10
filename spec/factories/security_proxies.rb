FactoryGirl.define do
  factory :security_proxy, class: 'SecurityProxy' do |f|
    name 'security/proxy'
    payload { FFaker::Lorem.words(10).join(' ') }
  end
end