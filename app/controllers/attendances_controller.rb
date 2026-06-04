class AttendancesController < ApplicationController
  before_action :require_authentication
  before_action :set_subject
  before_action :require_teacher_or_admin, only: [ :record, :create ]

  def index
    if Current.user.student?
      @attendances = @subject.attendances.where(user: Current.user).order(date: :desc)
      @total = @attendances.count
      if @total > 0
        @present = @attendances.where(status: "present").count
        @absent = @attendances.where(status: "absent").count
        @excused = @attendances.where(status: "excused").count
        @percentage = ((@present.to_f / @total) * 100).round(1)
      else
        @percentage = 100.0
      end
    else
      @students = @subject.students.order(:full_name)
      @attendance_stats = {}
      @students.each do |student|
        student_att = @subject.attendances.where(user: student)
        total = student_att.count
        present = student_att.where(status: "present").count
        @attendance_stats[student.id] = {
          total: total,
          present: present,
          percentage: total > 0 ? ((present.to_f / total) * 100).round(1) : 100.0
        }
      end
    end
  end

  def record
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @students = @subject.students.order(:full_name)
    @existing_attendances = @subject.attendances.where(date: @date).index_by(&:user_id)
  end

  def create
    @date = Date.parse(params[:date])
    records = params[:attendance] || {}

    Attendance.transaction do
      records.each do |user_id, status|
        student = @subject.students.find(user_id)
        att = @subject.attendances.find_or_initialize_by(user: student, date: @date)
        att.status = status
        att.recorded_by = Current.user
        att.save!
      end
    end

    redirect_to subject_attendances_path(@subject), notice: "Attendance for #{@date} saved successfully."
  rescue => e
    redirect_to record_subject_attendances_path(@subject, date: params[:date]), alert: "Failed to save attendance: #{e.message}"
  end

  private

  def set_subject
    @subject = Subject.find(params[:subject_id])
  end

  def require_teacher_or_admin
    unless Current.user.admin? || @subject.teacher == Current.user
      redirect_to @subject, alert: "Not authorized."
    end
  end
end
