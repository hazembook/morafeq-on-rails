class Quiz < ApplicationRecord
  belongs_to :subject
  has_many :quiz_questions, dependent: :destroy
  has_many :quiz_answers, through: :quiz_questions

  has_one_attached :quiz_file

  accepts_nested_attributes_for :quiz_questions, reject_if: :all_blank, allow_destroy: true

  validates :title, presence: true
  validates :due_at, presence: true
  validates :total_points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :quiz_file_type_valid, if: -> { quiz_file.attached? }
  validate :quiz_file_size_valid, if: -> { quiz_file.attached? }

  ALLOWED_TYPES = %w[
    application/pdf
    application/vnd.ms-powerpoint
    application/vnd.openxmlformats-officedocument.presentationml.presentation
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    image/png image/jpeg image/gif image/webp
  ].freeze

  MAX_FILE_SIZE = 50.megabytes

  def recalculate_total_points!
    update!(total_points: quiz_questions.sum(:points))
  end

  private

  def quiz_file_type_valid
    unless ALLOWED_TYPES.include?(quiz_file.content_type)
      errors.add(:quiz_file, "must be a PDF, PPT, DOCX, or image file")
    end
  end

  def quiz_file_size_valid
    if quiz_file.byte_size > MAX_FILE_SIZE
      errors.add(:quiz_file, "must be less than 50MB")
    end
  end
end
