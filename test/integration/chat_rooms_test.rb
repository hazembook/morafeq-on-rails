require "test_helper"

class ChatRoomsTest < ActionDispatch::IntegrationTest
  setup do
    @student_a = create(:user, full_name: "Student A")
    @student_b = create(:user, full_name: "Student B")
    @teacher = create(:user, role: :teacher, full_name: "Professor Teacher")
    @admin = create(:user, role: :admin, full_name: "System Admin")

    @subject = create(:subject, teacher: @teacher)
    @chat_room = @subject.chat_room || ChatRoom.find_by(subject: @subject)

    # Enroll student A
    create(:enrollment, user: @student_a, subject: @subject)
  end

  test "creating a private chat room and testing access" do
    # Sign in as A, create private room with B
    sign_in_as(@student_a)

    assert_difference "ChatRoom.where(is_private: true).count", 1 do
      post create_private_chat_rooms_path(user_id: @student_b.id)
    end

    private_room = ChatRoom.last
    assert_redirected_to private_room

    # Check that student A can view the private room
    get chat_room_path(private_room)
    assert_response :success
    assert_select "h1", text: "Student B"

    # Sign in as student B, check access and display name
    sign_in_as(@student_b)
    get chat_room_path(private_room)
    assert_response :success
    assert_select "h1", text: "Student A"

    # Sign in as teacher (not a participant), access should be denied
    sign_in_as(@teacher)
    get chat_room_path(private_room)
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "chat index lists authorized public and private rooms with correct names" do
    # Create private room
    private_room = ChatRoom.find_or_create_private(@student_a, @student_b)

    # Sign in student A
    sign_in_as(@student_a)
    get chat_rooms_path
    assert_response :success
    assert_match @chat_room.name, response.body
    assert_match "Student B", response.body

    # Student B should see Student A but not the subject room (since not enrolled)
    sign_in_as(@student_b)
    get chat_rooms_path
    assert_response :success
    assert_no_match @chat_room.name, response.body
    assert_match "Student A", response.body
  end

  test "seen status and read receipts tracking" do
    # Send a message from Student A
    message = Message.create!(chat_room: @chat_room, user: @student_a, content: "Hello!")

    # Sign in as Student B (not read yet)
    sign_in_as(@student_b)
    # Enroll B to let them view the room
    create(:enrollment, user: @student_b, subject: @subject)

    # Viewing the room should mark it as read
    assert_changes -> { ChatParticipant.find_by(user: @student_b, chat_room: @chat_room)&.last_read_message_id }, to: message.id do
      get chat_room_path(@chat_room)
    end
  end

  test "sending message with attachments" do
    sign_in_as(@student_a)

    # Valid message with text only
    assert_difference "Message.count", 1 do
      post chat_room_messages_path(@chat_room), params: { message: { content: "Text content" } }
    end

    # Valid message with attachment only (no content)
    file = fixture_file_upload("test.pdf", "application/pdf")
    assert_difference "Message.count", 1 do
      post chat_room_messages_path(@chat_room), params: { message: { content: "", attachments: [ file ] } }
    end

    assert Message.last.attachments.attached?

    # Invalid message (blank content, no attachments)
    assert_no_difference "Message.count" do
      post chat_room_messages_path(@chat_room), params: { message: { content: "" } }
    end
  end

  test "teacher and admin moderation of public subject chats" do
    message = Message.create!(chat_room: @chat_room, user: @student_a, content: "Student message")

    # Teacher can delete student's message
    sign_in_as(@teacher)
    assert_changes -> { Message.exists?(message.id) }, from: true, to: false do
      delete chat_room_message_path(@chat_room, message)
    end

    # Admin can delete any message too
    message2 = Message.create!(chat_room: @chat_room, user: @student_a, content: "Another student message")
    sign_in_as(@admin)
    assert_changes -> { Message.exists?(message2.id) }, from: true, to: false do
      delete chat_room_message_path(@chat_room, message2)
    end
  end
end
