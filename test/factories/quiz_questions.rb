FactoryBot.define do
  factory :quiz_question do
    quiz { nil }
    question { "MyText" }
    points { 1 }
  end
end
