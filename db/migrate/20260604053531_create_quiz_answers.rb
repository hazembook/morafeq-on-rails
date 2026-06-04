class CreateQuizAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_answers do |t|
      t.references :quiz_question, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :answer, null: false
      t.integer :score

      t.timestamps
    end
  end
end
