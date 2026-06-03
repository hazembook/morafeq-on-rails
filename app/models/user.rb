class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one_attached :avatar

  enum :role, { student: 0, teacher: 1, admin: 2 }

  validates :email_address, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :role, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
