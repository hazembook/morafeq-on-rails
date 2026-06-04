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

    if quiz_answer.file.attached?
      html << tag.div(class: "mt-2 pt-2 border-t border-gray-100 flex items-center gap-2") do
        safe_join([
          tag.svg(class: "w-4 h-4 text-blue-500 shrink-0", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
            tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z")
          end,
          link_to("Download Submitted File (#{quiz_answer.file.filename})", rails_blob_path(quiz_answer.file, disposition: "attachment"), class: "text-xs font-semibold text-blue-600 hover:text-blue-800 underline", target: "_blank")
        ])
      end
    end

    safe_join(html)
  end
end
