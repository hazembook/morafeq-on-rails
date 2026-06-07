module ApplicationHelper
  def scope_badge_class(scope_type)
    case scope_type
    when "College"
      "bg-purple-100 text-purple-700"
    when "Department"
      "bg-amber-100 text-amber-700"
    when "Subject"
      "bg-blue-100 text-blue-700"
    when nil, "General"
      "bg-green-100 text-green-700"
    else
      "bg-gray-100 text-gray-700"
    end
  end

  def format_quiz_answer(quiz_answer)
    return "" if quiz_answer.nil?

    question_type = quiz_answer.quiz_question.question_type
    html = []

    if quiz_answer.answer.present?
      case question_type
      when "match"
        # Match questions store the student's pairings as a JSON hash
        # (prompt → chosen answer); fall back to raw text if a legacy row
        # holds an unparseable value.
        begin
          parsed = JSON.parse(quiz_answer.answer)
          if parsed.is_a?(Hash)
            rendered_pairs = parsed.map do |k, v|
              tag.div(class: "flex items-center gap-2 text-sm text-gray-700") do
                safe_join([
                  tag.span(k, class: "font-medium text-gray-800"),
                  tag.span(I18n.locale == :ar ? "←" : "→", class: "text-gray-400 font-bold"),
                  tag.span(v.presence || t("quizzes.fields.no_match_selected"), class: v.present? ? "text-blue-600 font-semibold" : "text-red-500 italic")
                ])
              end
            end
            html << tag.div(safe_join(rendered_pairs), class: "space-y-1.5")
          else
            html << tag.p(quiz_answer.answer, class: "whitespace-pre-wrap")
          end
        rescue JSON::ParserError
          html << tag.p(quiz_answer.answer, class: "whitespace-pre-wrap")
        end
      else
        html << tag.p(quiz_answer.answer, class: "whitespace-pre-wrap")
      end
    end



    safe_join(html)
  end
end
