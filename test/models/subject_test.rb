require "test_helper"

class SubjectTest < ActiveSupport::TestCase
  test "validates presence of name" do
    subject = build(:subject, name: nil)
    assert_not subject.valid?
    assert_includes subject.errors[:name], "can't be blank"
  end

  test "validates presence of code" do
    subject = build(:subject, code: nil)
    assert_not subject.valid?
    assert_includes subject.errors[:code], "can't be blank"
  end

  test "validates uniqueness of code" do
    create(:subject, code: "CS101")
    subject = build(:subject, code: "CS101")
    assert_not subject.valid?
    assert_includes subject.errors[:code], "has already been taken"
  end

  test "belongs to department" do
    subject = create(:subject)
    assert_instance_of Department, subject.department
  end

  test "belongs to teacher (User)" do
    subject = create(:subject)
    assert_instance_of User, subject.teacher
    assert subject.teacher.teacher?
  end

  test "has_many enrollments" do
    subject = create(:subject)
    create(:enrollment, subject: subject)
    assert_equal 1, subject.enrollments.count
  end

  test "has_many students through enrollments" do
    subject = create(:subject)
    student = create(:user)
    create(:enrollment, subject: subject, user: student)
    assert_includes subject.students, student
  end
end
