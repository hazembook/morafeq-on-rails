class MakePostsScopeNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :posts, :scope_type, true
    change_column_null :posts, :scope_id, true
  end
end
