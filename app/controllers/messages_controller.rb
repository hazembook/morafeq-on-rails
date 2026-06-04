class MessagesController < ApplicationController
  before_action :require_authentication
  rescue_from Pundit::NotAuthorizedError, with: :message_not_authorized

  def create
    @room = ChatRoom.find(params[:chat_room_id])
    @message = @room.messages.build(message_params.merge(user: Current.user))

    if @message.save
      broadcast_message
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

  def broadcast_destroy
    Turbo::StreamsChannel.broadcast_remove_to(
      "chat_room_#{@message.chat_room_id}",
      target: "message_#{@message.id}"
    )
  end
end
