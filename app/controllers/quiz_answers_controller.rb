class QuizAnswersController < ApplicationController
  before_action :require_authentication
  before_action :set_subject_and_quiz

  def create
    answers_params = params[:answers] || {}

    questions = @quiz.quiz_questions
    if QuizAnswer.where(quiz_question_id: questions.select(:id), user_id: Current.user.id).any?
      redirect_to subject_quiz_path(@subject, @quiz), alert: t("flash.quizzes.already_submitted")
      return
    end

    if @quiz.locked? || @quiz.ended?
      redirect_to subject_quiz_path(@subject, @quiz), alert: t("flash.quizzes.locked_or_due")
      return
    end

    QuizAnswer.transaction do
      questions.each do |question|
        val = answers_params[question.id.to_s]

        QuizAnswer.create!(
          quiz_question: question,
          user: Current.user,
          answer: val.to_s
        )
      end
    end

    redirect_to subject_quiz_path(@subject, @quiz), notice: t("flash.quizzes.submitted")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to subject_quiz_path(@subject, @quiz), alert: t("flash.quizzes.submission_failed", message: e.message)
  end

  private

  def set_subject_and_quiz
    @subject = Subject.find(params[:subject_id])
    @quiz = @subject.quizzes.find(params[:quiz_id])
  end
end
