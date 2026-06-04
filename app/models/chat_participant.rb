class ChatParticipant < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room
  belongs_to :last_read_message, class_name: "Message", optional: true

  validates :user_id, uniqueness: { scope: :chat_room_id }
end
