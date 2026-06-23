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
    assert_includes material.errors[:file], "must be attached"
  end

  test "belongs to subject" do
    material = create(:material, :with_file)
    assert_instance_of Subject, material.subject
  end

  test "has one attached file" do
    assert_respond_to Material.new, :file
  end

  test "destroy hard-deletes material" do
    material = create(:material, :with_file)
    material.destroy
    assert_not Material.exists?(material.id)
  end

  test "validates file type is allowed" do
    material = build(:material)
    material.file.attach(
      io: StringIO.new("test content"),
      filename: "test.html",
      content_type: "text/html"
    )
    assert_not material.valid?
    assert_includes material.errors[:file], "file content does not match the declared type (detected: text/html)"
  end

  test "validates file size does not exceed maximum" do
    material = build(:material)
    material.file.attach(
      io: StringIO.new("test content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )
    original = Material::MAX_FILE_SIZE
    Material.send(:remove_const, :MAX_FILE_SIZE)
    Material.const_set(:MAX_FILE_SIZE, 1.byte)

    assert_not material.valid?
    assert_includes material.errors[:file], "must be less than 50MB"
  ensure
    Material.send(:remove_const, :MAX_FILE_SIZE)
    Material.const_set(:MAX_FILE_SIZE, original)
  end

  test "allows valid file" do
    material = build(:material, :with_file)
    assert material.valid?
  end

  test "allows text file" do
    material = build(:material)
    material.file.attach(
      io: StringIO.new("Hello world"),
      filename: "notes.txt",
      content_type: "text/plain"
    )
    assert material.valid?
  end

  test "allows markdown file" do
    material = build(:material)
    material.file.attach(
      io: StringIO.new("# Heading"),
      filename: "readme.md",
      content_type: "text/markdown"
    )
    assert material.valid?
  end

  test "rejects binary file with spoofed content type" do
    material = build(:material)
    material.file.attach(
      io: StringIO.new(+"MZ\x90\x00\x03\x00\x00\x00\x04\x00\x00\x00\xff\xff\x00\x00\xb8\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00".b),
      filename: "image.png",
      content_type: "image/png"
    )
    assert_not material.valid?
  end
end
