class SubjectsController < ApplicationController
  before_action :set_subject, only: [ :show ]

  def index
    @subjects = if Current.user.admin?
      Subject.includes(:department, :teacher).order(:code)
    elsif Current.user.teacher?
      Subject.where(teacher: Current.user).or(Subject.where(id: Current.user.enrollments.select(:subject_id))).includes(:department, :teacher).order(:code)
    else
      Subject.where(id: Current.user.enrollments.select(:subject_id)).includes(:department, :teacher).order(:code)
    end
  end

  def show
  end

  private

  def set_subject
    @subject = Subject.includes(:department, :teacher).find(params[:id])
  end
end
