class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :subjects, through: :enrollments
  has_many :taught_subjects, class_name: "Subject", foreign_key: :teacher_id, dependent: :nullify, inverse_of: :teacher
  has_one_attached :avatar

  enum :role, { student: 0, teacher: 1, admin: 2 }

  validates :email_address, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :role, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
