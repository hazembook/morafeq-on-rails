class CreateChatParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_participants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chat_room, null: false, foreign_key: true

      t.timestamps
    end
    add_index :chat_participants, [ :user_id, :chat_room_id ], unique: true
  end
end
