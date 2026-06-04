class AddLastReadMessageIdToChatParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :chat_participants, :last_read_message_id, :integer
  end
end
