class QuizAnswersController < ApplicationController
  before_action :require_authentication
  before_action :set_subject_and_quiz

  def create
    answers_params = params[:answers] || {}

    questions = @quiz.quiz_questions
    if QuizAnswer.where(quiz_question_id: questions.select(:id), user_id: Current.user.id).any?
      redirect_to subject_quiz_path(@subject, @quiz), alert: "You have already submitted answers for this quiz."
      return
    end

    if @quiz.due_at < Time.current
      redirect_to subject_quiz_path(@subject, @quiz), alert: "This quiz is past its due date."
      return
    end

    QuizAnswer.transaction do
      answers_params.each do |question_id, text|
        question = @quiz.quiz_questions.find(question_id)
        QuizAnswer.create!(
          quiz_question: q = question,
          user: Current.user,
          answer: text
        )
      end
    end

    redirect_to subject_quiz_path(@subject, @quiz), notice: "Your answers have been submitted successfully."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to subject_quiz_path(@subject, @quiz), alert: "Submission failed: #{e.message}"
  end

  private

  def set_subject_and_quiz
    @subject = Subject.find(params[:subject_id])
    @quiz = @subject.quizzes.find(params[:quiz_id])
  end
end
