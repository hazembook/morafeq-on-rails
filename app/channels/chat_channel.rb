class ChatChannel < ApplicationCable::Channel
  def subscribed
    room = ChatRoom.find(params[:id])
    stream_from "chat_room_#{room.id}"
  end

  def unsubscribed
  end
end
