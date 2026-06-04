class QuizQuestion < ApplicationRecord
  belongs_to :quiz
  has_many :quiz_answers, dependent: :destroy

  serialize :choices, coder: JSON
  attr_accessor :choices_text

  validates :question, presence: true
  validates :points, presence: true, numericality: { greater_than: 0 }
  validates :question_type, presence: true, inclusion: { in: %w[written mcq true_false match] }

  after_initialize :set_default_question_type, if: :new_record?
  before_validation :parse_choices_text
  after_save :recalculate_quiz_total_points
  after_destroy :recalculate_quiz_total_points

  def set_default_question_type
    self.question_type ||= "written"
  end

  def choices_text
    @choices_text || if choices.is_a?(Array)
      choices.join("\n")
                     elsif choices.is_a?(Hash)
      choices.map { |k, v| "#{k}: #{v}" }.join("\n")
                     else
      ""
                     end
  end

  def default_choices
    case question_type
    when "true_false"
      [ "True", "False" ]
    when "mcq"
      [ "", "", "", "" ]
    when "match"
      {}
    else
      nil
    end
  end

  private

  def parse_choices_text
    case question_type
    when "mcq"
      if @choices_text.present?
        self.choices = @choices_text.split("\n").map(&:strip).reject(&:blank?)
      end
    when "match"
      if @choices_text.present?
        hash = {}
        @choices_text.split("\n").each do |line|
          parts = line.split(":", 2)
          if parts.size == 2
            hash[parts[0].strip] = parts[1].strip
          end
        end
        self.choices = hash
      end
    when "true_false"
      self.choices = [ "True", "False" ]
    else
      self.choices = nil
    end
  end

  def recalculate_quiz_total_points
    quiz.recalculate_total_points!
  end
end
