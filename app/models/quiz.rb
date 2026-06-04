class Quiz < ApplicationRecord
  belongs_to :subject
  has_many :quiz_questions, dependent: :destroy
  has_many :quiz_answers, through: :quiz_questions

  accepts_nested_attributes_for :quiz_questions, reject_if: :all_blank, allow_destroy: true

  validates :title, presence: true
  validates :due_at, presence: true
  validates :total_points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def recalculate_total_points!
    update!(total_points: quiz_questions.sum(:points))
  end
end
