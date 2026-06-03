module FeedHelper
  def scope_options_for(user)
    subjects = if user.admin?
      Subject.includes(:department).order(:code)
    elsif user.teacher?
      user.taught_subjects.includes(:department).order(:code)
    else
      Subject.none
    end

    subjects.map do |s|
      [ "#{s.code} - #{s.name} (#{s.department.name})", "Subject-#{s.id}" ]
    end
  end
end
