FactoryBot.define do
  factory :subject do
    sequence(:name) { |n| "Subject #{n}" }
    sequence(:code) { |n| "SUB#{n}" }
    department
    teacher { association(:user, :teacher) }
  end
end
