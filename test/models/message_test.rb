require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @student = create(:user)
    @dm = ChatRoom.create!(is_private: true, name: "DM")
    @dm.chat_participants.create!(user: @teacher)
    @dm.chat_participants.create!(user: @student)
    @group = ChatRoom.create!(name: "Group Chat", is_private: false)
    @group.chat_participants.create!(user: @teacher)
    @group.chat_participants.create!(user: @student)
  end

  test "validates content when no attachments" do
    msg = Message.new(chat_room: @dm, user: @teacher, content: nil)
    assert_not msg.valid?
    assert_includes msg.errors[:content], "can't be blank"
  end

  test "allows nil content with attachments" do
    msg = Message.new(chat_room: @dm, user: @teacher, content: nil)
    msg.attachments.attach(
      io: StringIO.new("test"), filename: "test.pdf", content_type: "application/pdf"
    )
    assert msg.valid?
  end

  test "validates attachment size" do
    msg = Message.new(chat_room: @dm, user: @teacher, content: "Has attachment")
    msg.attachments.attach(
      io: StringIO.new("x" * (50.megabytes + 1)),
      filename: "large.pdf",
      content_type: "application/pdf"
    )
    assert_not msg.valid?
    assert_includes msg.errors[:attachments], "must be less than 50MB each"
  end

  test "seen_by? returns true when other participant has read" do
    msg = @dm.messages.create!(user: @teacher, content: "Hello")
    @dm.chat_participants.where(user: @student).update!(last_read_message_id: msg.id)
    assert msg.seen_by?(@teacher)
  end

  test "seen_by? returns false when nobody has read" do
    msg = @dm.messages.create!(user: @teacher, content: "Hello")
    assert_not msg.seen_by?(@teacher)
  end

  test "seen_by? returns false for nil user" do
    msg = @dm.messages.create!(user: @teacher, content: "Hello")
    assert_not msg.seen_by?(nil)
  end

  test "rejects binary attachment with spoofed content type" do
    msg = Message.new(chat_room: @dm, user: @teacher, content: "Look at this")
    msg.attachments.attach(
      io: StringIO.new(+"MZ\x90\x00\x03\x00\x00\x00\x04\x00\x00\x00\xff\xff\x00\x00\xb8\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00".b),
      filename: "image.png",
      content_type: "image/png"
    )
    assert_not msg.valid?
  end

  test "ordered scope ascends by created_at" do
    first = @dm.messages.create!(user: @teacher, content: "First", created_at: 2.hours.ago)
    second = @dm.messages.create!(user: @student, content: "Second", created_at: 1.hour.ago)
    assert_equal [ first, second ], @dm.messages.ordered.to_a
  end
end
