class MessagesController < ApplicationController
  before_action :require_authentication
  rescue_from Pundit::NotAuthorizedError, with: :message_not_authorized

  def create
    @room = ChatRoom.includes(:subject, chat_participants: :user, messages: :user).find(params[:chat_room_id])
    @message = @room.messages.build(message_params.merge(user: Current.user))

    if @message.save
      broadcast_message
      broadcast_sidebar_to_participants
      redirect_to @room
    else
      redirect_to @room, alert: @message.errors.full_messages.to_sentence
    end
  end

  def destroy
    @message = Message.find(params[:id])
    authorize @message

    room = @message.chat_room
    is_author = @message.user_id == Current.user.id

    @message.discard
    broadcast_destroy

    flash[:notice] = is_author ? t("chats.unsent") : t("chats.deleted_by_moderator")
    redirect_to room
  end

  private

  def require_authentication
    redirect_to new_session_path unless authenticated?
  end

  def message_not_authorized
    room = ChatRoom.find_by(id: params[:chat_room_id])
    redirect_to(room || chat_rooms_path, alert: t("common.not_authorized"))
  end

  def message_params
    params.require(:message).permit(:content, attachments: [])
  end

  def broadcast_message
    Turbo::StreamsChannel.broadcast_append_to(
      "chat_room_#{@room.id}",
      target: "messages",
      partial: "messages/message",
      locals: { message: @message }
    )
  end

  def broadcast_sidebar_to_participants
    @room.chat_participants.each do |participant|
      Turbo::StreamsChannel.broadcast_replace_to(
        "unread_#{participant.user_id}",
        target: "sidebar_room_#{@room.id}",
        partial: "chat_rooms/sidebar_room",
        locals: { room: @room, user: participant.user }
      )
    end
  end

  def broadcast_destroy
    Turbo::StreamsChannel.broadcast_remove_to(
      "chat_room_#{@message.chat_room_id}",
      target: "message_#{@message.id}"
    )
  end
end
