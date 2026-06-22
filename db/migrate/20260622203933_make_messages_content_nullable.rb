class MakeMessagesContentNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :messages, :content, true
  end
end
