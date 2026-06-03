class ChatRoom < ApplicationRecord
  belongs_to :subject, optional: true
  has_many :messages, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(created_at: :desc) }
end
