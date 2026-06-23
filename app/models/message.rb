class Message < ApplicationRecord
  belongs_to :user, inverse_of: :messages
  belongs_to :chat_room, inverse_of: :messages
  has_many_attached :attachments, dependent: :purge_later

  ALLOWED_ATTACHMENT_TYPES = (ALLOWED_IMAGE_TYPES + ALLOWED_DOCUMENT_TYPES + ALLOWED_MEDIA_TYPES).freeze

  after_create_commit :notify_recipients

  validates :content, presence: true, unless: -> { attachments.any? }
  validates :attachments, magic_bytes: { allowed: ALLOWED_ATTACHMENT_TYPES }, if: -> { attachments.any? }
  validate :attachments_type_valid, if: -> { attachments.any? }
  validate :attachments_size_valid, if: -> { attachments.any? }

  scope :ordered, -> { order(created_at: :asc) }

  def seen_by?(user_to_exclude)
    return false if user_to_exclude.nil?
    chat_room.chat_participants
             .where.not(user_id: user_to_exclude.id)
             .where("last_read_message_id >= ?", id)
             .exists?
  end

  private

  def attachments_type_valid
    attachments.each do |attachment|
      unless ALLOWED_ATTACHMENT_TYPES.include?(attachment.content_type)
        errors.add(:attachments, "must be an image, document, video, or audio file")
        break
      end
    end
  end

  def notify_recipients
    return unless chat_room.is_private?
    NotificationJob.perform_later(user, "new_message", self)
  end

  def attachments_size_valid
    attachments.each do |attachment|
      if attachment.byte_size > 50.megabytes
        errors.add(:attachments, "must be less than 50MB each")
      end
    end
  end
end
