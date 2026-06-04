class QuizQuestion < ApplicationRecord
  belongs_to :quiz
  has_many :quiz_answers, dependent: :destroy

  validates :question, presence: true
  validates :points, presence: true, numericality: { greater_than: 0 }

  after_save :recalculate_quiz_total_points
  after_destroy :recalculate_quiz_total_points

  private

  def recalculate_quiz_total_points
    quiz.recalculate_total_points!
  end
end
