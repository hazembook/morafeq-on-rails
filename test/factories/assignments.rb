FactoryBot.define do
  factory :assignment do
    sequence(:title) { |n| "Assignment #{n}" }
    subject
    due_at { 1.week.from_now }
    total_points { 100 }
  end
end
