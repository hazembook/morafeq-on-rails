class ChatRoomsController < ApplicationController
  before_action :require_authentication

  def index
    @rooms = ChatRoom.where(subject_id: available_subject_ids).ordered
  end

  def show
    @room = ChatRoom.find(params[:id])
    @messages = @room.messages.kept.ordered.includes(:user)
  end

  private

  def require_authentication
    redirect_to new_session_path unless authenticated?
  end

  def available_subject_ids
    if Current.user.admin?
      Subject.pluck(:id)
    else
      Subject.where(teacher: Current.user)
             .or(Subject.where(id: Enrollment.where(user_id: Current.user.id).select(:subject_id)))
             .pluck(:id)
    end
  end
end
