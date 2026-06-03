class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.text :content, null: false
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :scope_type, null: false
      t.integer :scope_id, null: false
      t.boolean :pinned, default: false, null: false
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :posts, [ :scope_type, :scope_id ]
    add_index :posts, :discarded_at
  end
end
