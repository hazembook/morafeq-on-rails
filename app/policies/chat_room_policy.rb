class ChatRoomPolicy < ApplicationPolicy
  def show?
    if record.is_private?
      record.chat_participants.exists?(user_id: user.id)
    else
      user.admin? ||
        record.subject&.teacher_id == user.id ||
        record.subject&.enrollments&.exists?(user_id: user.id)
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        subject_ids = Subject.where(teacher: user)
                             .or(Subject.where(id: Enrollment.where(user_id: user.id).select(:subject_id)))
                             .pluck(:id)
        public_rooms = scope.where(subject_id: subject_ids)
        private_rooms = scope.joins(:chat_participants)
                             .where(is_private: true, chat_participants: { user_id: user.id })
        scope.where(id: public_rooms.pluck(:id) + private_rooms.pluck(:id))
      end
    end
  end
end
