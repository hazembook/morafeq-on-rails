require "test_helper"

class CollegeTest < ActiveSupport::TestCase
  test "validates presence of name" do
    college = build(:college, name: nil)
    assert_not college.valid?
    assert_includes college.errors[:name], "can't be blank"
  end

  test "validates uniqueness of name" do
    create(:college, name: "Engineering")
    college = build(:college, name: "Engineering")
    assert_not college.valid?
    assert_includes college.errors[:name], "has already been taken"
  end

  test "has_many departments" do
    college = create(:college)
    create(:department, college: college)
    assert_equal 1, college.departments.count
  end

  test "destroys dependent departments" do
    college = create(:college)
    department = create(:department, college: college)
    college.destroy
    assert_raises(ActiveRecord::RecordNotFound) { department.reload }
  end
end
