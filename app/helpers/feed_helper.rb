module FeedHelper
  def scope_options_for(user)
    if user.admin?
      options = [ [ t("feed.scope_general_option", default: "General (University-wide)"), "General-0" ] ]

      College.order(:name).each do |c|
        options << [ "#{c.name} (#{t('feed.scopes.college', default: 'College')})", "College-#{c.id}" ]
      end

      Department.includes(:college).order(:name).each do |d|
        options << [ "#{d.name} (#{t('feed.scopes.department', default: 'Department')} - #{d.college.name})", "Department-#{d.id}" ]
      end

      Subject.includes(:department).order(:code).each do |s|
        options << [ "#{s.code} - #{s.name} (#{t('feed.scopes.subject', default: 'Subject')} - #{s.department.name})", "Subject-#{s.id}" ]
      end

      options
    elsif user.teacher?
      user.taught_subjects.includes(:department).order(:code).map do |s|
        [ "#{s.code} - #{s.name} (#{t('feed.scopes.subject', default: 'Subject')} - #{s.department.name})", "Subject-#{s.id}" ]
      end
    else
      []
    end
  end
end
