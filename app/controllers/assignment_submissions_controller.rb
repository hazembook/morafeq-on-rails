class AssignmentSubmissionsController < ApplicationController
  before_action :require_authentication
  before_action :set_subject_and_assignment

  def create
    if @assignment.assignment_submissions.exists?(user_id: Current.user.id)
      redirect_to subject_assignment_path(@subject, @assignment), alert: "You have already submitted this assignment."
      return
    end

    if @assignment.due_at < Time.current
      redirect_to subject_assignment_path(@subject, @assignment), alert: "This assignment is past its due date."
      return
    end

    @submission = @assignment.assignment_submissions.new(submission_params)
    @submission.user = Current.user

    if @submission.save
      redirect_to subject_assignment_path(@subject, @assignment), notice: "Your assignment has been submitted successfully."
    else
      redirect_to subject_assignment_path(@subject, @assignment), alert: "Submission failed: #{@submission.errors.full_messages.join(', ')}"
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
