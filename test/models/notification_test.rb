require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @recipient = create(:user)
    @actor = create(:user)
    @post = create(:post, author: @actor)
  end

  test "creates notification with valid attributes" do
    notification = Notification.new(
      recipient: @recipient, actor: @actor, action: "new_post", notifiable: @post
    )
    assert notification.valid?
  end

  test "validates presence of action" do
    notification = Notification.new(
      recipient: @recipient, actor: @actor, action: nil, notifiable: @post
    )
    assert_not notification.valid?
    assert_includes notification.errors[:action], "can't be blank"
  end

  test "belongs to recipient" do
    notification = create(:notification, recipient: @recipient, actor: @actor, notifiable: @post)
    assert_equal @recipient, notification.recipient
  end

  test "belongs to actor" do
    notification = create(:notification, recipient: @recipient, actor: @actor, notifiable: @post)
    assert_equal @actor, notification.actor
  end

  test "belongs to notifiable polymorphically" do
    notification = create(:notification, recipient: @recipient, actor: @actor, notifiable: @post)
    assert_equal @post, notification.notifiable
  end

  test "unread scope returns only unread notifications" do
    create(:notification, recipient: @recipient, actor: @actor, notifiable: @post)
    create(:notification, recipient: @recipient, actor: @actor, notifiable: @post, read_at: Time.current)
    assert_equal 1, Notification.unread.count
  end

  test "recent scope orders by created_at desc" do
    old = create(:notification, recipient: @recipient, actor: @actor, notifiable: @post, created_at: 1.day.ago)
    new = create(:notification, recipient: @recipient, actor: @actor, notifiable: @post, created_at: 1.hour.ago)
    assert_equal [ new, old ], Notification.recent.to_a
  end
end
