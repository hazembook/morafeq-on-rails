module FeedHelper
  def scope_options_for(user)
    if user.admin?
      options = [ [ "General (University-wide)", "General-0" ] ]

      College.order(:name).each do |c|
        options << [ "#{c.name} (College)", "College-#{c.id}" ]
      end

      Department.includes(:college).order(:name).each do |d|
        options << [ "#{d.name} (Department - #{d.college.name})", "Department-#{d.id}" ]
      end

      Subject.includes(:department).order(:code).each do |s|
        options << [ "#{s.code} - #{s.name} (Subject - #{s.department.name})", "Subject-#{s.id}" ]
      end

      options
    elsif user.teacher?
      user.taught_subjects.includes(:department).order(:code).map do |s|
        [ "#{s.code} - #{s.name} (Subject - #{s.department.name})", "Subject-#{s.id}" ]
      end
    else
      []
    end
  end
end
