class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes do |t|
      t.string :title, null: false
      t.references :subject, null: false, foreign_key: true
      t.datetime :due_at, null: false
      t.integer :total_points, null: false, default: 0

      t.timestamps
    end
  end
end
