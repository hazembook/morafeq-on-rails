require "test_helper"

class DepartmentTest < ActiveSupport::TestCase
  test "validates presence of name" do
    dept = build(:department, name: nil)
    assert_not dept.valid?
    assert_includes dept.errors[:name], "can't be blank"
  end

  test "belongs to college" do
    dept = create(:department)
    assert_instance_of College, dept.college
  end

  test "has_many subjects" do
    dept = create(:department)
    create(:subject, department: dept)
    assert_equal 1, dept.subjects.count
  end
end
