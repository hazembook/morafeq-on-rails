FactoryBot.define do
  factory :comment do
    post { nil }
    user { nil }
    content { "MyText" }
  end
end
