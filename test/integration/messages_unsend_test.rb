require "test_helper"

class MessagesUnsendTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user)
    @subject = create(:subject)
    # The callback creates a chat room for the subject
    @chat_room = @subject.chat_room || ChatRoom.find_by(subject: @subject)
    sign_in_as(@student)
  end

  test "user can unsend their own message within 5 minutes" do
    message = Message.create!(chat_room: @chat_room, user: @student, content: "Hello class!")

    assert_changes -> { message.reload.discarded? }, from: false, to: true do
      delete chat_room_message_path(@chat_room, message)
    end

    assert_redirected_to @chat_room
  end

  test "user cannot unsend their own message after 5 minutes" do
    message = Message.create!(chat_room: @chat_room, user: @student, content: "Hello class!", created_at: 6.minutes.ago)

    assert_no_changes -> { message.reload.discarded? } do
      delete chat_room_message_path(@chat_room, message)
    end

    assert_redirected_to @chat_room
  end

  test "user cannot unsend another user's message" do
    other_user = create(:user)
    message = Message.create!(chat_room: @chat_room, user: other_user, content: "Spam message")

    assert_no_changes -> { message.reload.discarded? } do
      delete chat_room_message_path(@chat_room, message)
    end

    assert_redirected_to @chat_room
  end
end
