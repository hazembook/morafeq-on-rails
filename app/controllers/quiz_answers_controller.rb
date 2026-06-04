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
      questions.each do |question|
        val = answers_params[question.id.to_s]

        file_param = nil
        text_val = ""

        if val.is_a?(Hash) || val.is_a?(ActionController::Parameters)
          val_h = val.to_unsafe_h
          if val_h.key?("file") || val_h.key?("text")
            file_param = val_h["file"]
            text_val = val_h["text"].to_s
          else
            text_val = val_h.to_json
          end
        else
          text_val = val.to_s
        end

        ans = QuizAnswer.new(
          quiz_question: question,
          user: Current.user,
          answer: text_val
        )
        ans.file.attach(file_param) if file_param.present?
        ans.save!
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
