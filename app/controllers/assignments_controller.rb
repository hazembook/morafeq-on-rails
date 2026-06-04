class AssignmentsController < ApplicationController
  before_action :require_authentication
  before_action :set_subject
  before_action :require_teacher_or_admin, only: [ :new, :create, :grade, :grade_submissions ]
  before_action :set_assignment, only: [ :show, :grade, :grade_submissions ]

  def show
    if Current.user.student?
      @submission = @assignment.assignment_submissions.find_by(user_id: Current.user.id)
      @submitted = @submission.present?
      @new_submission = @assignment.assignment_submissions.new(user: Current.user) unless @submitted
    end
  end

  def new
    @assignment = @subject.assignments.new
  end

  def create
    @assignment = @subject.assignments.new(assignment_params)

    if @assignment.save
      redirect_to subject_path(@subject), notice: "Assignment created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def grade
    @submissions = @assignment.assignment_submissions.includes(:user)
  end

  def grade_submissions
    grades = params[:grades] || {}
    feedbacks = params[:feedbacks] || {}

    AssignmentSubmission.transaction do
      grades.each do |submission_id, score|
        submission = @assignment.assignment_submissions.find(submission_id)
        feedback_text = feedbacks[submission_id.to_s]
        submission.update!(score: score.presence, feedback: feedback_text)
      end
    end

    redirect_to grade_subject_assignment_path(@subject, @assignment), notice: "Submissions graded successfully."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to grade_subject_assignment_path(@subject, @assignment), alert: "Failed to grade submissions: #{e.message}"
  end

  private

  def set_subject
    @subject = Subject.find(params[:subject_id])
  end

  def set_assignment
    @assignment = @subject.assignments.find(params[:id])
  end

  def require_teacher_or_admin
    unless Current.user.admin? || @subject.teacher == Current.user
      redirect_to @subject, alert: "Not authorized."
    end
  end

  def assignment_params
    params.require(:assignment).permit(:title, :description, :due_at, :total_points, :file)
  end
end
