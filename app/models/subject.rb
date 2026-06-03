class Subject < ApplicationRecord
  belongs_to :department
  belongs_to :teacher, class_name: "User"
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
