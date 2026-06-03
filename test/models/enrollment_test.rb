require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  test "belongs to user" do
    enrollment = create(:enrollment)
    assert_instance_of User, enrollment.user
  end

  test "belongs to subject" do
    enrollment = create(:enrollment)
    assert_instance_of Subject, enrollment.subject
  end

  test "validates uniqueness of user-scoped to subject" do
    enrollment = create(:enrollment)
    duplicate = build(:enrollment, user: enrollment.user, subject: enrollment.subject)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end
end
