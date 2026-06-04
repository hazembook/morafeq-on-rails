class MessagesController < ApplicationController
  before_action :require_authentication

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
    room = @message.chat_room

    is_author_recent = @message.user == Current.user && @message.created_at > 5.minutes.ago
    is_teacher = !room.is_private? && room.subject&.teacher == Current.user
    is_admin = Current.user.admin?

    if is_author_recent || is_teacher || is_admin
      @message.discard
      broadcast_destroy
      flash[:notice] = is_author_recent ? "Message unsent." : "Message deleted by moderator."
    else
      flash[:alert] = "You are not authorized to delete this message."
    end

    redirect_to room
  end

  private

  def require_authentication
    redirect_to new_session_path unless authenticated?
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
