class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :subjects, through: :enrollments
  has_many :taught_subjects, class_name: "Subject", foreign_key: :teacher_id, dependent: :restrict_with_error, inverse_of: :teacher
  has_many :authored_posts, class_name: "Post", foreign_key: :author_id, dependent: :destroy, inverse_of: :author
  has_many :chat_participants, dependent: :destroy
  has_many :chat_rooms, through: :chat_participants
  has_many :messages, dependent: :destroy
  has_many :quiz_answers, dependent: :destroy
  has_many :assignment_submissions, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :comments, dependent: :destroy, inverse_of: :user
  has_many :recorded_attendances, class_name: "Attendance", foreign_key: :recorded_by_id, dependent: :nullify, inverse_of: :recorded_by
  has_many :audit_logs, dependent: :destroy
  has_many :post_views, dependent: :destroy, inverse_of: :user
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy, inverse_of: :recipient
  has_many :acted_notifications, class_name: "Notification", foreign_key: :actor_id, dependent: :destroy, inverse_of: :actor
  has_one_attached :avatar, dependent: :purge_later

  enum :role, { student: 0, teacher: 1, admin: 2 }

  validates :email_address, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :role, presence: true

  def full_name
    return super if super.blank?
    I18n.t("db.users.#{super.parameterize(separator: '_')}", default: super)
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
