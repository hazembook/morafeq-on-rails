require "test_helper"

class ChatRoomTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @student = create(:user)
    @other = create(:user)
  end

  test "validates name for non-private rooms" do
    room = ChatRoom.new(is_private: false, name: nil)
    assert_not room.valid?
    assert_includes room.errors[:name], "can't be blank"
  end

  test "does not validate name for private rooms" do
    room = ChatRoom.new(is_private: true, name: nil)
    assert room.valid?
  end

  test "display_name returns other participant for private DM" do
    dm = ChatRoom.find_or_create_private(@teacher, @student)
    assert_equal @student.full_name, dm.display_name(@teacher)
    assert_equal @teacher.full_name, dm.display_name(@student)
  end

  test "display_name returns self chat for self-DM" do
    dm = ChatRoom.find_or_create_private(@teacher, @teacher)
    expected = I18n.t("chats.self_chat", default: "Self Chat")
    assert_equal expected, dm.display_name(@teacher)
  end

  test "display_name returns subject name for subject room" do
    subject = create(:subject, teacher: @teacher)
    room = subject.chat_room
    assert_equal subject.name, room.display_name(@teacher)
  end

  test "find_or_create_private creates new room" do
    room = ChatRoom.find_or_create_private(@teacher, @student)
    assert room.is_private?
    assert_includes room.participants, @teacher
    assert_includes room.participants, @student
  end

  test "find_or_create_private returns existing room" do
    first = ChatRoom.find_or_create_private(@teacher, @student)
    second = ChatRoom.find_or_create_private(@teacher, @student)
    assert_equal first, second
  end

  test "find_or_create_private creates self-chat" do
    room = ChatRoom.find_or_create_private(@teacher, @teacher)
    assert room.is_private?
    assert_equal 1, room.participants.count
    assert_includes room.participants, @teacher
  end

  test "find_or_create_private returns nil for nil args" do
    assert_nil ChatRoom.find_or_create_private(nil, @student)
    assert_nil ChatRoom.find_or_create_private(@teacher, nil)
    assert_nil ChatRoom.find_or_create_private(nil, nil)
  end

  test "ordered scope sorts by latest message" do
    room_a = ChatRoom.create!(is_private: true, name: "A")
    room_a.chat_participants.create!(user: @teacher)
    room_a.messages.create!(user: @teacher, content: "Old", created_at: 1.day.ago)

    room_b = ChatRoom.create!(is_private: true, name: "B")
    room_b.chat_participants.create!(user: @teacher)
    room_b.messages.create!(user: @teacher, content: "Recent", created_at: 1.hour.ago)

    assert_equal [ room_b, room_a ], ChatRoom.ordered.to_a
  end
end
