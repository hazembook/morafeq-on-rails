class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User", inverse_of: :notifications
  belongs_to :actor, class_name: "User", inverse_of: :acted_notifications
  belongs_to :notifiable, polymorphic: true

  validates :action, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
end
