class AddQuestionTypeAndChoicesToQuizQuestions < ActiveRecord::Migration[8.1]
  def change
    add_column :quiz_questions, :question_type, :string
    add_column :quiz_questions, :choices, :text
  end
end
