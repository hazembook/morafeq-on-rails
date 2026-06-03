FactoryBot.define do
  factory :user do
    full_name { "Test User" }
    email_address { "user#{rand(10000)}@example.com" }
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
