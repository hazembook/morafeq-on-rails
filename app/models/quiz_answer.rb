class QuizAnswer < ApplicationRecord
  belongs_to :quiz_question
  belongs_to :user

  validates :answer, presence: true
  validates :user_id, uniqueness: { scope: :quiz_question_id, message: "has already answered this question" }
  validates :score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: ->(ans) { ans.quiz_question&.points || 0 }
  }, allow_nil: true
end
