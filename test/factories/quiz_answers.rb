FactoryBot.define do
  factory :quiz_answer do
    quiz_question { nil }
    user { nil }
    answer { "MyText" }
    score { 1 }
  end
end
