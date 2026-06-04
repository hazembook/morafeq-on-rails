class CreateAssignmentsAndSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments do |t|
      t.references :subject, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :due_at, null: false
      t.integer :total_points, null: false, default: 100

      t.timestamps
    end

    create_table :assignment_submissions do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :score
      t.text :feedback

      t.timestamps
    end
  end
end
