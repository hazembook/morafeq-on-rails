class ChatRoomPolicy < ApplicationPolicy
  def show?
    if record.is_private?
      record.participants.include?(user)
    else
      user.admin? ||
        record.subject&.teacher_id == user.id ||
        record.subject&.enrollments&.exists?(user_id: user.id)
    end
  end
end
