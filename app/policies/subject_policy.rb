class SubjectPolicy < ApplicationPolicy
  def index?
    user.admin?
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
