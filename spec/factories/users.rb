FactoryGirl.define do
  factory :user, class: 'Atmosphere::User' do
    email { Faker::Internet.email }
    login { SecureRandom.hex(8) }
    password '12345678'
    password_confirmation { password }
    authentication_token { login }

    trait :developer do
      roles [:developer]
    end

    factory :developer, traits: [:developer]
  end
end