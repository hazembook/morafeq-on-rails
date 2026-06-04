require "test_helper"

class ChatParticipantTest < ActiveSupport::TestCase
  test "chat room ordered scope" do
    rooms = ChatRoom.ordered.to_a
    assert_not_nil rooms
  end
end
