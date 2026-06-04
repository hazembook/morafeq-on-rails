require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, role: :student, full_name: "Student Profile Test")
    @teacher = create(:user, role: :teacher, full_name: "Teacher Profile Test")
    @admin = create(:user, role: :admin, full_name: "Admin Profile Test")

    @subject = create(:subject, teacher: @teacher)
    create(:enrollment, user: @student, subject: @subject)
  end

  test "should redirect to sign in if not authenticated" do
    get profile_path
    assert_redirected_to new_session_path
  end

  test "should display student profile with academic stats" do
    # Create quiz & answer
    quiz = create(:quiz, subject: @subject, total_points: 10)
    q1 = quiz.quiz_questions.create!(question: "Q1", question_type: "true_false", points: 10)
    create(:quiz_answer, quiz_question: q1, user: @student, answer: "True", score: 8)

    # Create assignment & submission
    assignment = Assignment.create!(title: "Test Assignment", due_at: 2.days.from_now, total_points: 50, subject: @subject)
    sub = assignment.assignment_submissions.new(user: @student)
    sub.file.attach(io: File.open(Rails.root.join("test/fixtures/files/test.pdf")), filename: "test.pdf", content_type: "application/pdf")
    sub.save!
    sub.update!(score: 45)

    # Create attendance
    create(:attendance, user: @student, subject: @subject, date: Date.today, status: "present", recorded_by: @teacher)

    sign_in_as(@student)
    get profile_path
    assert_response :success

    # Verify calculated stats are visible in response
    assert_match "80.0%", response.body # Quiz avg
    assert_match "90.0%", response.body # Assignment avg
    assert_match "100.0%", response.body # Attendance rate
    assert_match "Student Profile Test", response.body
  end

  test "should display teacher profile with teaching stats" do
    # Create attendance & grades to populate stats
    create(:attendance, user: @student, subject: @subject, date: Date.today, status: "present", recorded_by: @teacher)

    sign_in_as(@teacher)
    get profile_path
    assert_response :success

    assert_match "Teacher Profile Test", response.body
    assert_match "1 Enrolled Students", response.body
  end

  test "should display admin profile with system-wide diagnostics" do
    sign_in_as(@admin)
    get profile_path
    assert_response :success

    assert_match "Admin Profile Test", response.body
    assert_match "System Management Diagnostics", response.body
    assert_match "Total Students", response.body
  end

  test "should edit profile" do
    sign_in_as(@student)
    get edit_profile_path
    assert_response :success
  end

  test "should update profile info" do
    sign_in_as(@student)
    patch profile_path, params: {
      user: {
        full_name: "Updated Student Name",
        bio: "This is a new bio."
      }
    }
    assert_redirected_to profile_path
    @student.reload
    assert_equal "Updated Student Name", @student.full_name
    assert_equal "This is a new bio.", @student.bio
  end
end
