require "test_helper"

class AssignmentSubmissionTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  test "rejects binary file with spoofed content type" do
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
    submission = AssignmentSubmission.new(assignment: assignment, user: student)
    submission.file.attach(
      io: StringIO.new(+"MZ\x90\x00\x03\x00\x00\x00\x04\x00\x00\x00\xff\xff\x00\x00\xb8\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00".b),
      filename: "image.png",
      content_type: "image/png"
    )
    assert_not submission.valid?
  end

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
