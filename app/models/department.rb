class Department < ApplicationRecord
  belongs_to :college
  has_many :subjects, dependent: :destroy

  validates :name, presence: true
end
