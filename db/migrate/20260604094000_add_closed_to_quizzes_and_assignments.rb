class AddClosedToQuizzesAndAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :quizzes, :closed, :boolean, default: false, null: false
    add_column :assignments, :closed, :boolean, default: false, null: false
  end
end
