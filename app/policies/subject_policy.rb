class SubjectPolicy < ApplicationPolicy
  def index? = true
  def show? = true

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(teacher: user)
             .or(scope.where(id: Enrollment.where(user_id: user.id).select(:subject_id)))
      end
    end
  end
end

  def show?
    true
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || user.teacher?
  end

  def destroy?
    user.admin?
  end
end
