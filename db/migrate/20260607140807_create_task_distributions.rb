class CreateTaskDistributions < ActiveRecord::Migration[8.1]
  def change
    create_table :task_distributions do |t|
      t.references :assigner, null: false, foreign_key: { to_table: :users }
      t.references :assignee, null: false, foreign_key: { to_table: :users }
      t.references :scope, polymorphic: true

      t.boolean :manage_posts, default: false, null: false
      t.boolean :manage_materials, default: false, null: false
      t.boolean :manage_quizzes, default: false, null: false
      t.boolean :manage_schedules, default: false, null: false
      t.boolean :manage_attendance, default: false, null: false
      t.boolean :manage_chat, default: false, null: false
      t.boolean :manage_enrollments, default: false, null: false
      t.boolean :manage_prerequisites, default: false, null: false
      t.boolean :manage_exam_grades, default: false, null: false
      t.boolean :manage_subjects, default: false, null: false
      t.boolean :manage_departments, default: false, null: false

      t.timestamps
    end

    add_index :task_distributions, [ :scope_type, :scope_id ]
  end
end
