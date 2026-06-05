class AssignmentSubmission < ApplicationRecord
  belongs_to :assignment, inverse_of: :assignment_submissions
  belongs_to :user, inverse_of: :assignment_submissions

  has_one_attached :file, dependent: :purge_later

  validates :user_id, uniqueness: { scope: :assignment_id, message: "has already submitted this assignment" }
  validates :score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: ->(sub) { sub.assignment&.total_points || 0 }
  }, allow_nil: true

  validate :file_attached
  validate :file_type_valid, if: -> { file.attached? }
  validate :file_size_valid, if: -> { file.attached? }

  ALLOWED_TYPES = %w[
    application/pdf
    application/vnd.ms-powerpoint
    application/vnd.openxmlformats-officedocument.presentationml.presentation
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    image/png image/jpeg image/gif image/webp
  ].freeze

  MAX_FILE_SIZE = 50.megabytes

  after_update_commit :broadcast_grade_update

  private

  def broadcast_grade_update
    if saved_change_to_score? || saved_change_to_feedback?
      broadcast_replace_to(
        "assignment_#{assignment_id}_user_#{user_id}",
        target: "student_submission_status",
        partial: "assignments/student_submission",
        locals: { submission: self, assignment: assignment }
      )
    end
  end

  def file_attached
    errors.add(:file, "must be attached to submit") unless file.attached?
  end

  def file_type_valid
    unless ALLOWED_TYPES.include?(file.content_type)
      errors.add(:file, "must be a PDF, PPT, DOCX, or image file")
    end
  end

  def file_size_valid
    if file.byte_size > MAX_FILE_SIZE
      errors.add(:file, "must be less than 50MB")
    end
  end
end
