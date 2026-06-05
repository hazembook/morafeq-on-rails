class CreatePostViews < ActiveRecord::Migration[8.1]
  def change
    create_table :post_views do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :post_views, [ :post_id, :user_id ], unique: true
  end
end
