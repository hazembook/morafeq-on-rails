class QuizAnswer < ApplicationRecord
  belongs_to :quiz_question
  belongs_to :user

  has_one_attached :file

  validates :answer, presence: true, unless: -> { file.attached? }
  validates :user_id, uniqueness: { scope: :quiz_question_id, message: "has already answered this question" }
  validates :score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: ->(ans) { ans.quiz_question&.points || 0 }
  }, allow_nil: true

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

  private

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
