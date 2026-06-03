class Message < ApplicationRecord
  include Discard::Model

  belongs_to :user
  belongs_to :chat_room

  validates :content, presence: true

  scope :ordered, -> { order(created_at: :asc) }
end
