FactoryBot.define do
  factory :post do
    content { "This is a test post about something interesting." }
    association :author, factory: :user
    scope { association(:subject) }
    pinned { false }

    trait :pinned do
      pinned { true }
    end
  end
end
