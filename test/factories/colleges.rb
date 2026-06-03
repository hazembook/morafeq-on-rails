FactoryBot.define do
  factory :college do
    sequence(:name) { |n| "College #{n}" }
  end
end
