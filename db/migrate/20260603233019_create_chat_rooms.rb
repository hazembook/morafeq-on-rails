class CreateChatRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_rooms do |t|
      t.string :name, null: false
      t.boolean :is_private, default: false, null: false
      t.references :subject, foreign_key: true

      t.timestamps
    end
  end
end
