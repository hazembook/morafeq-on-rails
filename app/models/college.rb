class College < ApplicationRecord
  has_many :departments, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
