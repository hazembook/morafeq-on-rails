class AddParticipantKeyToChatRooms < ActiveRecord::Migration[8.1]
  def change
    add_column :chat_rooms, :participant_key, :string
    add_index :chat_rooms, :participant_key, unique: true, where: "is_private = true"
  end
end
