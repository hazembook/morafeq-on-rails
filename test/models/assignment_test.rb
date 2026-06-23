require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @subject = create(:subject, teacher: @teacher)
  end

  test "validates presence of title" do
    assignment = Assignment.new(title: nil, subject: @subject, due_at: 1.week.from_now, total_points: 100)
    assert_not assignment.valid?
    assert_includes assignment.errors[:title], "can't be blank"
  end

  test "validates presence of due_at" do
    assignment = Assignment.new(title: "HW", subject: @subject, due_at: nil, total_points: 100)
    assert_not assignment.valid?
    assert_includes assignment.errors[:due_at], "can't be blank"
  end

  test "validates presence of total_points" do
    assignment = Assignment.new(title: "HW", subject: @subject, due_at: 1.week.from_now, total_points: nil)
    assert_not assignment.valid?
    assert_includes assignment.errors[:total_points], "can't be blank"
  end

  test "validates total_points is non-negative" do
    assignment = Assignment.new(title: "HW", subject: @subject, due_at: 1.week.from_now, total_points: -1)
    assert_not assignment.valid?
    assert_includes assignment.errors[:total_points], "must be greater than or equal to 0"
  end

  test "validates file type" do
    assignment = Assignment.new(title: "HW", subject: @subject, due_at: 1.week.from_now, total_points: 100)
    assignment.file.attach(io: StringIO.new("bad"), filename: "test.exe", content_type: "application/x-msdownload")
    assert_not assignment.valid?
    assert_includes assignment.errors[:file], "must be a PDF, PPT, DOCX, or image file"
  end

  test "validates file size" do
    assignment = Assignment.new(title: "HW", subject: @subject, due_at: 1.week.from_now, total_points: 100)
    assignment.file.attach(io: StringIO.new("x" * (50.megabytes + 1)), filename: "big.pdf", content_type: "application/pdf")
    assert_not assignment.valid?
    assert_includes assignment.errors[:file], "must be less than 50MB"
  end

  test "status returns open by default" do
    assignment = create(:assignment, subject: @subject, due_at: 1.week.from_now)
    assert_equal "open", assignment.status
  end

  test "status returns ended when past due" do
    assignment = create(:assignment, subject: @subject, due_at: 1.day.ago)
    assert_equal "ended", assignment.status
  end

  test "status returns closed when closed flag set" do
    assignment = create(:assignment, subject: @subject, due_at: 1.week.from_now, closed: true)
    assert_equal "closed", assignment.status
  end

  test "status returns locked when locked flag set" do
    assignment = create(:assignment, subject: @subject, due_at: 1.week.from_now, locked: true)
    assert_equal "locked", assignment.status
  end

  test "ended? returns true when past due" do
    assignment = create(:assignment, subject: @subject, due_at: 1.day.ago)
    assert assignment.ended?
  end

  test "ended? returns false when future due" do
    assignment = create(:assignment, subject: @subject, due_at: 1.week.from_now)
    assert_not assignment.ended?
  end

  test "rejects binary file with spoofed content type" do
    assignment = Assignment.new(title: "HW", subject: @subject, due_at: 1.week.from_now, total_points: 100)
    assignment.file.attach(
      io: StringIO.new(+"MZ\x90\x00\x03\x00\x00\x00\x04\x00\x00\x00\xff\xff\x00\x00\xb8\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00".b),
      filename: "image.png",
      content_type: "image/png"
    )
    assert_not assignment.valid?
  end

  test "owner returns subject teacher" do
    assignment = create(:assignment, subject: @subject)
    assert_equal @teacher, assignment.owner
  end
end
