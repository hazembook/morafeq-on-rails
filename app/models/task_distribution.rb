class TaskDistribution < ApplicationRecord
  FLAGS = %w[
    manage_posts manage_materials manage_quizzes manage_schedules
    manage_attendance manage_chat manage_enrollments manage_prerequisites
    manage_exam_grades manage_subjects manage_departments
  ].freeze

  belongs_to :assigner, class_name: "User", inverse_of: :assigned_task_distributions
  belongs_to :assignee, class_name: "User", inverse_of: :task_distributions
  belongs_to :scope, polymorphic: true, optional: true

  validates :scope_type, inclusion: { in: %w[College Department Subject] }, allow_nil: true
end
