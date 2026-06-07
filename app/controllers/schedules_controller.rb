class SchedulesController < ApplicationController
  before_action :require_authentication
  before_action :set_subject
  before_action :authorize_subject_show, only: [ :index ]
  before_action :require_teacher_or_admin, only: [ :new, :create, :destroy ]

  def index
    @schedules = @subject.schedules.order(:day, :start_time)
  end

  def new
    @schedule = @subject.schedules.new
  end

  def create
    @schedule = @subject.schedules.new(schedule_params)
    if @schedule.save
      redirect_to subject_schedules_path(@subject), notice: t("flash.schedules.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule = @subject.schedules.find(params[:id])
    @schedule.destroy
    redirect_to subject_schedules_path(@subject), notice: t("flash.schedules.deleted")
  end

  private

  def set_subject
    @subject = Subject.find(params[:subject_id])
  end

  def require_teacher_or_admin
    unless Current.user.admin? || @subject.teacher == Current.user
      redirect_to @subject, alert: t("common.not_authorized")
    end
  end

  def schedule_params
    params.require(:schedule).permit(:day, :start_time, :end_time, :room)
  end
end
