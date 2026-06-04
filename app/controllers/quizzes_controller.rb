class QuizzesController < ApplicationController
  before_action :require_authentication
  before_action :set_subject
  before_action :require_teacher_or_admin, only: [ :new, :create, :edit, :update, :destroy, :grade, :grade_answers ]
  before_action :set_quiz, only: [ :show, :edit, :update, :destroy, :grade, :grade_answers ]

  def index
    @quizzes = @subject.quizzes.order(due_at: :asc)
  end

  def show
    @questions = @quiz.quiz_questions

    if Current.user.student?
      @answers = QuizAnswer.where(quiz_question_id: @questions.select(:id), user_id: Current.user.id)
      @submitted = @answers.any?

      unless @submitted
        @answers_map = {}
        @questions.each do |q|
          @answers_map[q.id] = QuizAnswer.new(quiz_question: q, user: Current.user)
        end
      end
    end
  end

  def new
    @quiz = @subject.quizzes.new
    @quiz.quiz_questions.build(question_type: "mcq", points: 5, question: "Question 1: MCQ Sample", choices: [ "Option A", "Option B" ])
    @quiz.quiz_questions.build(question_type: "true_false", points: 5, question: "Question 2: True/False Sample")
  end

  def create
    @quiz = @subject.quizzes.new(quiz_params)
    @quiz.total_points = @quiz.quiz_questions.map(&:points).compact.sum

    if @quiz.save
      redirect_to subject_quizzes_path(@subject), notice: t("flash.quizzes.created")
    else
      @quiz.quiz_questions.build if @quiz.quiz_questions.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @quiz.assign_attributes(quiz_params)
    @quiz.total_points = @quiz.quiz_questions.map(&:points).compact.sum

    if @quiz.save
      redirect_to params[:redirect_to].presence || subject_quiz_path(@subject, @quiz), notice: t("flash.quizzes.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quiz.destroy
    redirect_to subject_quizzes_path(@subject), notice: t("flash.quizzes.deleted")
  end


  def grade
    @answers_by_student = QuizAnswer.joins(:quiz_question)
                                    .where(quiz_questions: { quiz_id: @quiz.id })
                                    .includes(:user, :quiz_question)
                                    .group_by(&:user)
  end

  def grade_answers
    grades = params[:grades] || {}

    QuizAnswer.transaction do
      grades.each do |answer_id, score|
        answer = QuizAnswer.joins(:quiz_question).where(quiz_questions: { quiz_id: @quiz.id }).find(answer_id)
        answer.update!(score: score.presence)
      end
    end

    redirect_to grade_subject_quiz_path(@subject, @quiz), notice: t("flash.quizzes.graded")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to grade_subject_quiz_path(@subject, @quiz), alert: t("flash.quizzes.grade_failed", message: e.message)
  end

  private

  def set_subject
    @subject = Subject.find(params[:subject_id])
  end

  def set_quiz
    @quiz = @subject.quizzes.find(params[:id])
  end

  def require_teacher_or_admin
    unless Current.user.admin? || @subject.teacher == Current.user
      redirect_to @subject, alert: t("common.not_authorized")
    end
  end

  def quiz_params
    params.require(:quiz).permit(:title, :due_at, :locked, :closed, quiz_questions_attributes: [ :id, :question, :points, :question_type, :_destroy, choices: [] ])
  end
end
