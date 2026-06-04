class CreateQuizQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.text :question, null: false
      t.integer :points, null: false

      t.timestamps
    end
  end
end
