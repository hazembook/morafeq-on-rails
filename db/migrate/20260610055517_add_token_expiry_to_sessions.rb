class AddTokenExpiryToSessions < ActiveRecord::Migration[8.1]
  def up
    add_column :sessions, :token, :string
    add_column :sessions, :expires_at, :datetime
    add_column :sessions, :last_used_at, :datetime

    Session.reset_column_information
    Session.find_each do |s|
      s.update_columns(
        token: SecureRandom.hex(32),
        expires_at: 30.days.from_now,
        last_used_at: s.updated_at
      )
    end

    change_column_null :sessions, :token, false
    change_column_null :sessions, :expires_at, false
    add_index :sessions, :token, unique: true
  end

  def down
    remove_index :sessions, :token
    remove_column :sessions, :token
    remove_column :sessions, :expires_at
    remove_column :sessions, :last_used_at
  end
end
