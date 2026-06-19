class ChatRoom < ApplicationRecord
  belongs_to :subject, optional: true, inverse_of: :chat_room
  has_many :messages, dependent: :destroy, inverse_of: :chat_room
  has_many :chat_participants, dependent: :destroy, inverse_of: :chat_room
  has_many :participants, through: :chat_participants, source: :user

  validates :name, presence: true, unless: :is_private?

  # Order by last message time, falling back to room creation when empty
  scope :ordered, -> {
    left_joins(:messages)
      .group("chat_rooms.id")
      .order(Arel.sql("COALESCE(MAX(messages.created_at), chat_rooms.created_at) DESC"))
  }

  def display_name(current_user)
    if is_private?
      other_participant = participants.where.not(id: current_user.id).first
      other_participant ? other_participant.full_name : I18n.t("chats.self_chat", default: "Self Chat")
    else
      subject ? subject.name : name
    end
  end

  def self.participant_key_for(user_a, user_b)
    [ user_a.id, user_b&.id ].compact.sort.join("-")
  end

  def self.find_or_create_private(user_a, user_b)
    return nil if user_a.nil? || user_b.nil?

    key = participant_key_for(user_a, user_b)

    where(is_private: true, participant_key: key).first ||
      create_private_room!(user_a, user_b, key)
  end

  def self.create_private_room!(user_a, user_b, key)
    transaction do
      room = create!(is_private: true, name: "Private Chat", participant_key: key)
      room.chat_participants.create!(user: user_a)
      room.chat_participants.create!(user: user_b) unless user_a == user_b
      room
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
