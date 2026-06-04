class Message < ApplicationRecord
  include Discard::Model

  belongs_to :user
  belongs_to :chat_room
  has_many_attached :attachments

  validates :content, presence: true, unless: -> { attachments.any? }
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

  def attachments_size_valid
    attachments.each do |attachment|
      if attachment.byte_size > 50.megabytes
        errors.add(:attachments, "must be less than 50MB each")
      end
    end
  end
end
