class MessagePolicy < ApplicationPolicy
  def destroy?
    user.admin? ||
      (record.user_id == user.id && record.created_at > 5.minutes.ago) ||
      (!record.chat_room.is_private? && record.chat_room.subject&.teacher_id == user.id)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
