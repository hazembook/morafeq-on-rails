class MessagesController < ApplicationController
  before_action :require_authentication

  def create
    @room = ChatRoom.find(params[:chat_room_id])
    @message = @room.messages.build(content: params[:message][:content], user: Current.user)

    if @message.save
      broadcast_message
      redirect_to @room
    else
      redirect_to @room, alert: "Message cannot be blank."
    end
  end

  def destroy
    @message = Message.find(params[:id])
    if @message.user == Current.user && @message.created_at > 5.minutes.ago
      @message.discard
      broadcast_destroy
    end
    redirect_to @message.chat_room
  end

  private

  def require_authentication
    redirect_to new_session_path unless authenticated?
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
