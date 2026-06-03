require "test_helper"

class MaterialTest < ActiveSupport::TestCase
  test "validates presence of title" do
    material = build(:material, :with_file, title: nil)
    assert_not material.valid?
    assert_includes material.errors[:title], "can't be blank"
  end

  test "validates presence of file" do
    material = build(:material)
    assert_not material.valid?
    assert_includes material.errors[:file], "can't be blank"
  end

  test "belongs to subject" do
    material = create(:material, :with_file)
    assert_instance_of Subject, material.subject
  end

  test "has one attached file" do
    assert_respond_to Material.new, :file
  end

  test "discard soft-deletes material" do
    material = create(:material, :with_file)
    material.discard
    assert material.discarded?
    assert material.discarded_at.present?
  end

  test "kept scope excludes discarded" do
    material = create(:material, :with_file)
    material.discard
    assert_not_includes Material.kept, material
  end
end
