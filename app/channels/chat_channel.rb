class ChatChannel < ApplicationCable::Channel
  def subscribed
    room = ChatRoom.find(params[:id])
    reject_unauthorized_subscription unless authorized?(room)
    stream_from "chat_room_#{room.id}"
  end

  def unsubscribed
  end

  private

  def authorized?(room)
    ChatRoomPolicy.new(current_user, room).show?
  end
end
