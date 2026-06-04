class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :subject
  belongs_to :recorded_by, class_name: "User"

  validates :date, presence: true
  validates :status, presence: true, inclusion: { in: %w[present absent excused] }
  validates :user_id, uniqueness: { scope: [ :subject_id, :date ], message: "attendance has already been recorded for this date" }
end
