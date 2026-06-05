require "test_helper"

class NotificationJobTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @subject = create(:subject, teacher: @teacher)
    @student = create(:user)
    create(:enrollment, user: @student, subject: @subject)
  end

  test "creates notification for post scoped to subject" do
    post = create(:post, author: @teacher, scope: @subject)

    NotificationJob.perform_now(@teacher, "new_post", post)

    notification = @student.notifications.last
    assert_equal @teacher, notification.actor
    assert_equal "new_post", notification.action
    assert_equal post, notification.notifiable
  end

  test "does not notify the actor" do
    post = create(:post, author: @teacher, scope: @subject)

    NotificationJob.perform_now(@teacher, "new_post", post)

    assert_empty @teacher.notifications
  end

  test "creates notification for material upload" do
    material = create(:material, :with_file, subject: @subject)

    NotificationJob.perform_now(@teacher, "new_material", material)

    assert_equal 1, @student.notifications.count
    assert_equal "new_material", @student.notifications.last.action
  end

  test "creates notification for new assignment" do
    assignment = create(:assignment, subject: @subject)

    NotificationJob.perform_now(@teacher, "new_assignment", assignment)

    assert_equal 1, @student.notifications.count
    assert_equal "new_assignment", @student.notifications.last.action
  end

  test "creates notification for new quiz" do
    quiz = create(:quiz, subject: @subject)

    NotificationJob.perform_now(@teacher, "new_quiz", quiz)

    assert_equal 1, @student.notifications.count
    assert_equal "new_quiz", @student.notifications.last.action
  end

  test "creates notification for DM message" do
    chat_room = ChatRoom.create!(is_private: true, name: "DM")
    chat_room.chat_participants.create!(user: @teacher)
    chat_room.chat_participants.create!(user: @student)
    message = chat_room.messages.create!(user: @teacher, content: "Hello")

    NotificationJob.perform_now(@teacher, "new_message", message)

    assert_equal 1, @student.notifications.count
    assert_equal "new_message", @student.notifications.last.action
  end

  test "does not create notification for group chat message" do
    subject = create(:subject, teacher: @teacher)
    chat_room = ChatRoom.create!(name: "Group Chat", is_private: false, subject: subject)
    chat_room.chat_participants.create!(user: @teacher)
    chat_room.chat_participants.create!(user: @student)
    message = chat_room.messages.create!(user: @teacher, content: "Hello group")

    NotificationJob.perform_now(@teacher, "new_message", message)

    assert_equal 0, @student.notifications.count
  end

  test "notifies department-scoped post recipients" do
    department = @subject.department
    another_subject = create(:subject, department: department)
    another_student = create(:user)
    create(:enrollment, user: another_student, subject: another_subject)
    post = create(:post, author: @teacher, scope: department, scope_type: "Department")

    NotificationJob.perform_now(@teacher, "new_post", post)

    [ @student, another_student ].each do |student|
      assert_equal 1, student.notifications.count
    end
  end

  test "notifies college-scoped post recipients" do
    college = @subject.department.college
    another_dept = create(:department, college: college)
    another_subject = create(:subject, department: another_dept)
    another_student = create(:user)
    create(:enrollment, user: another_student, subject: another_subject)
    post = create(:post, author: @teacher, scope: college, scope_type: "College")

    NotificationJob.perform_now(@teacher, "new_post", post)

    [ @student, another_student ].each do |student|
      assert_equal 1, student.notifications.count
    end
  end

  test "notifies all users for general post" do
    other_user = create(:user)
    post = create(:post, author: @teacher, scope: nil, scope_type: nil)

    NotificationJob.perform_now(@teacher, "new_post", post)

    [ @student, other_user ].each do |user|
      assert_equal 1, user.notifications.count
    end
  end

  test "uses new_pinned_post action for pinned posts" do
    post = create(:post, author: @teacher, scope: @subject, pinned: true)

    NotificationJob.perform_now(@teacher, "new_pinned_post", post)

    notification = @student.notifications.last
    assert_equal "new_pinned_post", notification.action
  end
end
