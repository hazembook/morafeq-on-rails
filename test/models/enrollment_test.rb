require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  test "default status is enrolled" do
    enrollment = Enrollment.new(user: build(:user), subject: build(:subject))
    assert enrollment.enrolled?
    assert_equal "enrolled", enrollment.status
  end

  test "enum values" do
    assert_equal 0, Enrollment.statuses[:enrolled]
    assert_equal 1, Enrollment.statuses[:completed]
    assert_equal 2, Enrollment.statuses[:failed]
    assert_equal 3, Enrollment.statuses[:dropped]
  end

  test "active scope returns only enrolled" do
    subject = create(:subject)
    student1 = create(:user)
    student2 = create(:user)
    e1 = create(:enrollment, user: student1, subject: subject, status: :enrolled)
    e2 = create(:enrollment, user: student2, subject: subject, status: :completed)

    active = Enrollment.active
    assert_includes active, e1
    assert_not_includes active, e2
  end

  test "finished scope returns completed and failed" do
    subject = create(:subject)
    student1 = create(:user)
    student2 = create(:user)
    student3 = create(:user)
    e1 = create(:enrollment, user: student1, subject: subject, status: :completed)
    e2 = create(:enrollment, user: student2, subject: subject, status: :failed)
    e3 = create(:enrollment, user: student3, subject: subject, status: :enrolled)

    finished = Enrollment.finished
    assert_includes finished, e1
    assert_includes finished, e2
    assert_not_includes finished, e3
  end
end
