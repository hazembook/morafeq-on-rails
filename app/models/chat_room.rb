class ChatRoom < ApplicationRecord
  belongs_to :subject, optional: true
  has_many :messages, dependent: :destroy
  has_many :chat_participants, dependent: :destroy
  has_many :participants, through: :chat_participants, source: :user

  validates :name, presence: true, unless: :is_private?

  scope :ordered, -> { order(created_at: :desc) }

  def display_name(current_user)
    if is_private?
      other_participant = participants.where.not(id: current_user.id).first
      other_participant ? other_participant.full_name : "Self Chat"
    else
      name
    end
  end

  def self.find_or_create_private(user_a, user_b)
    return nil if user_a.nil? || user_b.nil?

    room = if user_a == user_b
      joins(:chat_participants)
        .where(is_private: true)
        .group("chat_rooms.id")
        .having("count(distinct chat_participants.user_id) = 1 AND sum(case when chat_participants.user_id = ? then 1 else 0 end) = 1", user_a.id)
        .first
    else
      joins(:chat_participants)
        .where(is_private: true)
        .where(chat_participants: { user_id: [ user_a.id, user_b.id ] })
        .group("chat_rooms.id")
        .having("count(distinct chat_participants.user_id) = 2")
        .first
    end

    return room if room

    transaction do
      room = create!(is_private: true, name: "Private Chat")
      room.chat_participants.create!(user: user_a)
      room.chat_participants.create!(user: user_b) unless user_a == user_b
      room
    end
  end
end
