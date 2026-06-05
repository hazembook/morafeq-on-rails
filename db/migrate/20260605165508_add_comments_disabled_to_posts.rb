class AddCommentsDisabledToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :comments_disabled, :boolean, default: true, null: false
  end
end
