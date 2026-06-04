require "test_helper"

class QuizAnswerTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "quiz answer score update broadcasts turbo stream" do
    student = create(:user)
    teacher = create(:user, role: :teacher)
    subject = create(:subject, teacher: teacher)
    quiz = create(:quiz, subject: subject)
    question = create(:quiz_question, quiz: quiz, points: 10, question_type: "true_false")
    answer = create(:quiz_answer, quiz_question: question, user: student, answer: "True")

    assert_broadcasts("quiz_#{quiz.id}_user_#{student.id}", 1) do
      answer.update!(score: 8)
    end
  end
end
