class Assignment < ApplicationRecord
  belongs_to :subject, inverse_of: :assignments
  has_many :assignment_submissions, dependent: :destroy

  has_one_attached :file, dependent: :purge_later

  after_create_commit :notify_recipients

  validates :title, presence: true
  validates :due_at, presence: true
  validates :total_points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :file_type_valid, if: -> { file.attached? }
  validate :file_size_valid, if: -> { file.attached? }

  def owner
    subject.teacher
  end

  def status
    if locked?
      "locked"
    elsif closed?
      "closed"
    elsif due_at < Time.current
      "ended"
    else
      "open"
    end
  end

  def ended?
    due_at < Time.current || closed?
  end

  MAX_FILE_SIZE = 50.megabytes

  private

  def notify_recipients
    NotificationJob.perform_later(owner, "new_assignment", self)
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
