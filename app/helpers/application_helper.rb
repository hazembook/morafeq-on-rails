module ApplicationHelper
  def scope_badge_class(scope_type)
    case scope_type
    when "College"
      "bg-purple-100 text-purple-700"
    when "Department"
      "bg-amber-100 text-amber-700"
    when "Subject"
      "bg-blue-100 text-blue-700"
    else
      "bg-gray-100 text-gray-700"
    end
  end
end
