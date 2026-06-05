require "test_helper"

class AssignmentSubmissionTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  test "assignment submission score and feedback update broadcasts turbo stream" do
    student = create(:user)
    teacher = create(:user, role: :teacher)
    subject = create(:subject, teacher: teacher)
    assignment = Assignment.create!(
      title: "Lab Assignment 1",
      description: "Submit your solution",
      due_at: 2.days.from_now,
      total_points: 50,
      subject: subject
    )

    file = fixture_file_upload("test.pdf", "application/pdf")
    submission = AssignmentSubmission.create!(
      assignment: assignment,
      user: student,
      file: file
    )

    assert_broadcasts("assignment_#{assignment.id}_user_#{student.id}", 1) do
      submission.update!(score: 45, feedback: "Great work!")
    end
  end
end
