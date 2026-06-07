require "test_helper"

class AdminEnrollmentsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @subject = create(:subject)
    @student = create(:user)
    sign_in_as(@admin)
  end

  test "admin can enroll a student in a subject" do
    assert_difference -> { Enrollment.count } => 1, -> { AuditLog.count } => 1 do
      post admin_subject_enrollments_path(@subject), params: { user_id: @student.id }
    end

    assert_redirected_to admin_subject_path(@subject)
    follow_redirect!
    assert_match I18n.t("flash.admin.enrollment_created"), flash[:notice]

    assert @subject.students.include?(@student)
    audit_log = AuditLog.last
    assert_equal "create", audit_log.action
    assert_equal "Enrollment", audit_log.auditable_type
  end

  test "admin can remove a student from a subject" do
    enrollment = create(:enrollment, user: @student, subject: @subject)

    assert_difference -> { Enrollment.count } => -1, -> { AuditLog.count } => 1 do
      delete admin_subject_enrollment_path(@subject, enrollment)
    end

    assert_redirected_to admin_subject_path(@subject)
    follow_redirect!
    assert_match I18n.t("flash.admin.enrollment_deleted"), flash[:notice]

    assert_not @subject.students.reload.include?(@student)
    audit_log = AuditLog.last
    assert_equal "destroy", audit_log.action
    assert_equal "Enrollment", audit_log.auditable_type
  end

  test "non-admin cannot manage enrollments" do
    sign_out
    student = create(:user)
    sign_in_as(student)

    post admin_subject_enrollments_path(@subject), params: { user_id: @student.id }
    assert_redirected_to root_path

    delete admin_subject_enrollment_path(@subject, create(:enrollment, subject: @subject))
    assert_redirected_to root_path
  end

  test "cannot enroll the same student twice" do
    create(:enrollment, user: @student, subject: @subject)

    assert_no_difference [ -> { Enrollment.count }, -> { AuditLog.count } ] do
      post admin_subject_enrollments_path(@subject), params: { user_id: @student.id }
    end

    assert_redirected_to admin_subject_path(@subject)
  end
end
