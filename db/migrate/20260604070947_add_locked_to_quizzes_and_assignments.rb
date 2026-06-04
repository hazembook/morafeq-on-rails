class AddLockedToQuizzesAndAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :quizzes, :locked, :boolean, default: false, null: false
    add_column :assignments, :locked, :boolean, default: false, null: false
  end
end
