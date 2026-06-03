class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.text :content, null: false
      t.references :user, null: false, foreign_key: true
      t.references :chat_room, null: false, foreign_key: true
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :messages, :discarded_at
  end
end
