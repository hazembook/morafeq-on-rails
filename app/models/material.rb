class Material < ApplicationRecord
  belongs_to :subject, inverse_of: :materials
  has_one_attached :file, dependent: :purge_later

  after_create_commit :notify_recipients

  validates :title, presence: true
  validate :file_attached
  validate :file_type_valid, if: -> { file.attached? }
  validate :file_size_valid, if: -> { file.attached? }

  def owner
    subject.teacher
  end

  MAX_FILE_SIZE = 50.megabytes

  private

  def notify_recipients
    NotificationJob.perform_later(owner, "new_material", self)
  end

  def file_attached
    errors.add(:file, "must be attached") unless file.attached?
  end

  def file_type_valid
    unless ALLOWED_UPLOAD_TYPES.include?(file.content_type)
      errors.add(:file, "must be a PDF, PPT, DOCX, or image file")
    end
  end

  def file_size_valid
    if file.byte_size > MAX_FILE_SIZE
      errors.add(:file, "must be less than 50MB")
    end
  end
end
