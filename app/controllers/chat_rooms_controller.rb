class ChatRoomsController < ApplicationController
  before_action :require_authentication
  before_action :set_sidebar_data, only: [ :index, :show ]

  def index
  end

  def show
    @room = ChatRoom.find(params[:id])
    authorize @room

    @participant = @room.chat_participants.find_or_create_by!(user: Current.user)
    last_message = @room.messages.kept.last
    if last_message && @participant.last_read_message_id != last_message.id
      @participant.update!(last_read_message_id: last_message.id)
      broadcast_read_status(last_message)
    end

    @messages = @room.messages.kept.ordered.includes(:user)
  end

  def create_private
    other_user = User.find(params[:user_id])
    @room = ChatRoom.find_or_create_private(Current.user, other_user)
    redirect_to @room
  end

  def typing
    @room = ChatRoom.find(params[:id])
    authorize @room, :show?

    Turbo::StreamsChannel.broadcast_replace_to(
      "chat_room_#{@room.id}",
      target: "typing_indicator",
      partial: "chat_rooms/typing_indicator",
      locals: { user: Current.user, typing: params[:typing] }
    )

    head :ok
  end

  private

  def broadcast_read_status(last_message)
    # Broadcast seen status update for this message
    Turbo::StreamsChannel.broadcast_replace_to(
      "chat_room_#{@room.id}",
      target: "message_#{last_message.id}_seen",
      html: "<span data-role=\"seen-status\" class=\"text-[10px] font-light\">#{I18n.t("chats.seen")}</span>"
    )
  end

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

  def set_sidebar_data
    public_rooms = ChatRoom.where(subject_id: available_subject_ids)
    private_rooms = ChatRoom.joins(:chat_participants).where(is_private: true, chat_participants: { user_id: Current.user.id })
    @rooms = ChatRoom.where(id: public_rooms.pluck(:id) + private_rooms.pluck(:id))
                     .ordered
                     .includes(:subject, messages: :user, chat_participants: :user)
    @users = User.where.not(id: Current.user.id).order(:full_name)
  end
end
