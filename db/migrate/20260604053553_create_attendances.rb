class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.date :date, null: false
      t.string :status, null: false
      t.references :recorded_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :attendances, [ :user_id, :subject_id, :date ], unique: true
  end
end
