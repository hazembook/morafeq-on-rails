class AssignmentSubmissionsController < ApplicationController
  before_action :require_authentication
  before_action :set_subject_and_assignment
  before_action :authorize_subject_show, only: [ :create ]

  def create
    if @assignment.assignment_submissions.exists?(user_id: Current.user.id)
      redirect_to subject_assignment_path(@subject, @assignment), alert: t("flash.assignments.already_submitted")
      return
    end

    if @assignment.locked? || @assignment.ended?
      redirect_to subject_assignment_path(@subject, @assignment), alert: t("flash.assignments.locked_or_due")
      return
    end

    @submission = @assignment.assignment_submissions.new(submission_params)
    @submission.user = Current.user

    if @submission.save
      redirect_to subject_assignment_path(@subject, @assignment), notice: t("flash.assignments.submitted")
    else
      redirect_to subject_assignment_path(@subject, @assignment), alert: t("flash.assignments.submission_failed", errors: @submission.errors.full_messages.join(", "))
    end
  end

  private

  def set_subject_and_assignment
    @subject = Subject.find(params[:subject_id])
    @assignment = @subject.assignments.find(params[:assignment_id])
  end

  def submission_params
    params.require(:assignment_submission).permit(:file)
  end
end
