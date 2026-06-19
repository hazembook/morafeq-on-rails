class RemoveDiscardedAtFromPostsMaterialsMessages < ActiveRecord::Migration[8.1]
  def change
    remove_column :posts, :discarded_at, :datetime
    remove_column :materials, :discarded_at, :datetime
    remove_column :messages, :discarded_at, :datetime
  end
end
