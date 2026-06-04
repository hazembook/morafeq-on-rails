class MessagePolicy < ApplicationPolicy
  def destroy?
    # 1. Author can unsend/delete their own message within 5 minutes
    return true if record.user_id == user.id && record.created_at > 5.minutes.ago

    # 2. Admin can moderate (delete) any message
    return true if user.admin?

    # 3. Teacher can moderate (delete) any message in their subject's chat room
    if !record.chat_room.is_private? && record.chat_room.subject&.teacher_id == user.id
      return true
    end

    false
  end
end
