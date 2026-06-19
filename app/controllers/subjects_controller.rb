class SubjectsController < ApplicationController
  before_action :set_subject, only: [ :show ]
  before_action :authorize_subject_show, only: [ :show ]

  def index
    set_meta_tags title: t("subjects.title")
    @subjects = if Current.user.admin?
      Subject.includes(:department, :teacher).order(:code)
    elsif Current.user.teacher?
      Subject.where(teacher: Current.user).or(Subject.where(id: Current.user.enrollments.select(:subject_id))).includes(:department, :teacher).order(:code)
    else
      Subject.where(id: Current.user.enrollments.select(:subject_id)).includes(:department, :teacher).order(:code)
    end
  end

  def show
    set_meta_tags title: @subject.name
    @materials = @subject.materials.order(created_at: :desc).limit(5)
    @quizzes = @subject.quizzes.order(due_at: :desc)
    @assignments = @subject.assignments.order(due_at: :desc)
    @schedules = @subject.schedules.order(:day, :start_time)
    @posts = Post.where(scope_type: "Subject", scope_id: @subject.id).order(pinned: :desc, created_at: :desc).limit(5)

    if Current.user.student?
      @student_attendances = @subject.attendances.where(user: Current.user)
      total = @student_attendances.count
      if total > 0
        present = @student_attendances.where(status: "present").count
        @attendance_rate = ((present.to_f / total) * 100).round(1)
      else
        @attendance_rate = nil
      end
    else
      @student_count = @subject.students.count
    end
  end

  private

  def set_subject
    @subject = Subject.includes(:department, :teacher).find(params[:id])
  end
end
