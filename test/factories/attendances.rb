FactoryBot.define do
  factory :attendance do
    user { nil }
    subject { nil }
    date { "2026-06-04" }
    status { "MyString" }
    recorded_by { nil }
  end
end
