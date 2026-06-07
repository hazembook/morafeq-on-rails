class QuizAnswer < ApplicationRecord
  belongs_to :quiz_question, inverse_of: :quiz_answers
  belongs_to :user, inverse_of: :quiz_answers

  validates :answer, presence: true
  validates :user_id, uniqueness: { scope: :quiz_question_id, message: "has already answered this question" }
  validates :score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: ->(ans) { ans.quiz_question&.points || 0 }
  }, allow_nil: true

  after_update_commit :broadcast_grade_update

  private

  def broadcast_grade_update
    if saved_change_to_score?
      quiz = quiz_question.quiz
      # Re-fetch the whole submission so the partial renders the full status block
      answers = QuizAnswer.where(quiz_question_id: quiz.quiz_question_ids, user_id: user_id)
      questions = quiz.quiz_questions

      broadcast_replace_to(
        "quiz_#{quiz.id}_user_#{user_id}",
        target: "quiz_submission_status",
        partial: "quizzes/student_submission",
        locals: { quiz: quiz, answers: answers, questions: questions }
      )
    end
  end
end
