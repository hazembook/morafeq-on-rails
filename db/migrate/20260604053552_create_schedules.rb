class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.references :subject, null: false, foreign_key: true
      t.integer :day, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.string :room, null: false

      t.timestamps
    end
  end
end
