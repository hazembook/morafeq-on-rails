class NotificationJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(actor, action, notifiable)
    recipients_for(notifiable).where.not(id: actor.id).distinct.find_each do |recipient|
      Notification.create!(recipient: recipient, actor: actor, action: action, notifiable: notifiable)
    end
  end

  private

  def recipients_for(notifiable)
    case notifiable
    when Post
      post_recipients(notifiable)
    when Material
      notifiable.subject.students
    when Message
      message_recipients(notifiable)
    when Assignment
      notifiable.subject.students
    when Quiz
      notifiable.subject.students
    else
      User.none
    end
  end

  def post_recipients(post)
    case post.scope_type
    when "Subject"
      post.scope&.students || User.none
    when "Department"
      dept = post.scope
      return User.none unless dept.is_a?(Department)
      User.joins(enrollments: { subject: :department })
          .where(departments: { id: dept.id })
          .distinct
    when "College"
      college = post.scope
      return User.none unless college.is_a?(College)
      User.joins(enrollments: { subject: { department: :college } })
          .where(colleges: { id: college.id })
          .distinct
    else
      User.all
    end
  end

  def message_recipients(message)
    return User.none unless message.chat_room&.is_private?
    message.chat_room.participants
  end
end
