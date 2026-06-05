class Enrollment < ApplicationRecord
  belongs_to :user, inverse_of: :enrollments
  belongs_to :subject, inverse_of: :enrollments

  validates :user_id, uniqueness: { scope: :subject_id }
end
