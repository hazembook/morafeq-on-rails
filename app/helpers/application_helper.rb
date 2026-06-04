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
    return "" if quiz_answer.nil? || quiz_answer.answer.blank?

    question_type = quiz_answer.quiz_question.question_type

    case question_type
    when "match"
      begin
        parsed = JSON.parse(quiz_answer.answer)
        if parsed.is_a?(Hash)
          rendered_pairs = parsed.map do |k, v|
            tag.div(class: "flex items-center gap-2 text-sm text-gray-700") do
              safe_join([
                tag.span(k, class: "font-medium text-gray-800"),
                tag.span("→", class: "text-gray-400 font-bold"),
                tag.span(v.presence || "No match selected", class: v.present? ? "text-blue-600 font-semibold" : "text-red-500 italic")
              ])
            end
          end
          tag.div(safe_join(rendered_pairs), class: "space-y-1.5")
        else
          quiz_answer.answer
        end
      rescue JSON::ParserError
        quiz_answer.answer
      end
    else
      quiz_answer.answer
    end
  end
end
