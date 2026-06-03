FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Department #{n}" }
    college
  end
end
