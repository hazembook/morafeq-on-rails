class QuizQuestion < ApplicationRecord
  belongs_to :quiz, inverse_of: :quiz_questions
  has_many :quiz_answers, dependent: :destroy, inverse_of: :quiz_question

  serialize :choices, coder: JSON

  validates :question, presence: true
  validates :points, presence: true, numericality: { greater_than: 0 }
  validates :question_type, presence: true, inclusion: { in: %w[mcq true_false] }
  validate :choices_count_valid, if: -> { question_type == "mcq" }

  before_validation :set_default_question_type
  before_validation :set_default_choices
  before_validation :clean_and_parse_choices
  after_save :recalculate_quiz_total_points, if: :saved_change_to_points?
  after_destroy :recalculate_quiz_total_points

  attr_writer :choices_text

  def choices_text
    @choices_text || if choices.is_a?(Array)
      choices.join("\n")
                     else
      ""
                     end
  end

  def default_choices
    case question_type
    when "true_false"
      [ "True", "False" ]
    when "mcq"
      [ "", "" ]
    else
      nil
    end
  end

  private

  def set_default_question_type
    self.question_type ||= "mcq"
  end

  def set_default_choices
    self.choices ||= default_choices if new_record?
  end

  def choices_count_valid
    if choices.blank? || !choices.is_a?(Array) || choices.size < 2
      errors.add(:choices, "must have at least 2 options")
    end
  end

  def clean_and_parse_choices
    case question_type
    when "true_false"
      self.choices = [ "True", "False" ]
    when "mcq"
      if choices.is_a?(Array)
        self.choices = choices.map(&:strip).reject(&:blank?)
      elsif @choices_text.present?
        self.choices = @choices_text.split("\n").map(&:strip).reject(&:blank?)
      end
    else
      self.choices = nil
    end
  end

  def recalculate_quiz_total_points
    quiz.recalculate_total_points!
  end
end
