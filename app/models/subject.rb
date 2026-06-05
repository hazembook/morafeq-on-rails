class Subject < ApplicationRecord
  belongs_to :department
  belongs_to :teacher, class_name: "User"
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user
  has_many :materials, dependent: :destroy

  has_one :chat_room, dependent: :destroy
  has_many :quizzes, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :attendances, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true

  def name
    return super if super.blank?
    I18n.t("db.subjects.#{code}", default: super)
  end

  after_create_commit :create_chat_room

  private

  def create_chat_room
    ChatRoom.create!(name: name_before_type_cast, subject: self)
  end
end
