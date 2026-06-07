class Enrollment < ApplicationRecord
  belongs_to :user, inverse_of: :enrollments
  belongs_to :subject, inverse_of: :enrollments

  validates :user_id, uniqueness: { scope: :subject_id }

  enum :status, { enrolled: 0, completed: 1, failed: 2, dropped: 3 }, default: :enrolled
  scope :active, -> { where(status: :enrolled) }
  scope :finished, -> { where(status: [ :completed, :failed ]) }
end
