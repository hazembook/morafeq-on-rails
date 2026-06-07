class SubjectPolicy < ApplicationPolicy
  def index? = true

  def show?
    user.admin? || record.teacher_id == user.id || record.enrollments.exists?(user_id: user.id)
  end

  def create? = user.admin?
  def new? = create?

  def update?
    user.admin? || record.teacher_id == user.id
  end
  def edit? = update?

  def destroy? = user.admin?

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
