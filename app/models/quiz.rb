class Quiz < ApplicationRecord
  belongs_to :subject, inverse_of: :quizzes
  has_many :quiz_questions, dependent: :destroy
  has_many :quiz_answers, through: :quiz_questions

  accepts_nested_attributes_for :quiz_questions, reject_if: :all_blank, allow_destroy: true

  after_create_commit :notify_recipients

  validates :title, presence: true
  validates :due_at, presence: true
  validates :total_points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def owner
    subject.teacher
  end

  def recalculate_total_points!
    update!(total_points: quiz_questions.sum(:points))
  end

  def status
    if locked?
      "locked"
    elsif closed?
      "closed"
    elsif due_at < Time.current
      "ended"
    else
      "open"
    end
  end

  def ended?
    due_at < Time.current || closed?
  end

  private

  def notify_recipients
    NotificationJob.perform_later(owner, "new_quiz", self)
  end
end
