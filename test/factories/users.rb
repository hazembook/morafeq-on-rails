FactoryBot.define do
  factory :user do
    full_name { "Test User" }
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :student }

    trait :teacher do
      role { :teacher }
    end

    trait :admin do
      role { :admin }
    end
  end
end
