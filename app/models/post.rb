class Post < ApplicationRecord
  include Discard::Model

  belongs_to :author, class_name: "User"
  belongs_to :scope, polymorphic: true, optional: true
  has_many_attached :attachments

  validates :content, presence: true
  validates :scope_type, inclusion: { in: %w[College Department Subject] }, allow_nil: true

  scope :pinned_first, -> { order(pinned: :desc, created_at: :desc) }
  scope :not_pinned, -> { where(pinned: false) }

  def self.feed_for(user)
    return kept.order(pinned: :desc, created_at: :desc) if user.admin?

    subject_ids = user.enrollments.select(:subject_id)
    subject_ids = user.taught_subjects.select(:id).or(Subject.where(id: subject_ids)) if user.teacher?

    department_ids = Subject.where(id: subject_ids).select(:department_id)
    college_ids = Department.where(id: department_ids).select(:college_id)

    kept.where(
      "scope_type IS NULL OR " \
      "(scope_type = 'Subject' AND scope_id IN (?)) OR " \
      "(scope_type = 'Department' AND scope_id IN (?)) OR " \
      "(scope_type = 'College' AND scope_id IN (?))",
      subject_ids, department_ids, college_ids
    ).order(pinned: :desc, created_at: :desc)
  end
end
