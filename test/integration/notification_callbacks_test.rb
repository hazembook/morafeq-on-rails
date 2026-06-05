require "test_helper"

class NotificationCallbacksTest < ActionDispatch::IntegrationTest
  setup do
    @teacher = create(:user, :teacher)
    @subject = create(:subject, teacher: @teacher)
    @student = create(:user)
    create(:enrollment, user: @student, subject: @subject)
  end

  test "creating a post enqueues notification job" do
    assert_enqueued_jobs(1, only: NotificationJob) do
      Post.create!(author: @teacher, content: "Test post", scope: @subject, scope_type: "Subject")
    end
  end

  test "creating a pinned post enqueues notification job" do
    assert_enqueued_jobs(1, only: NotificationJob) do
      Post.create!(author: @teacher, content: "Pinned", scope: @subject, scope_type: "Subject", pinned: true)
    end
  end

  test "creating a post with no scope still enqueues" do
    assert_enqueued_jobs(1, only: NotificationJob) do
      Post.create!(author: @teacher, content: "General")
    end
  end

  test "creating a material enqueues notification job" do
    mat = Material.new(title: "Test", subject: @subject)
    mat.file.attach(io: StringIO.new("content"), filename: "test.pdf", content_type: "application/pdf")
    assert_enqueued_jobs(1, only: NotificationJob) do
      mat.save!
    end
  end

  test "creating a DM message enqueues notification job" do
    dm = ChatRoom.create!(is_private: true, name: "DM")
    dm.chat_participants.create!(user: @teacher)
    dm.chat_participants.create!(user: @student)
    assert_enqueued_jobs(1, only: NotificationJob) do
      dm.messages.create!(user: @teacher, content: "Hello DM")
    end
  end

  test "creating a group message does not enqueue notification job" do
    group = ChatRoom.create!(name: "Group", is_private: false, subject: @subject)
    group.chat_participants.create!(user: @teacher)
    group.chat_participants.create!(user: @student)
    assert_enqueued_jobs(0, only: NotificationJob) do
      group.messages.create!(user: @teacher, content: "Hello group")
    end
  end

  test "creating an assignment enqueues notification job" do
    assert_enqueued_jobs(1, only: NotificationJob) do
      Assignment.create!(title: "HW", subject: @subject, due_at: 1.week.from_now, total_points: 100)
    end
  end

  test "creating a quiz enqueues notification job" do
    assert_enqueued_jobs(1, only: NotificationJob) do
      Quiz.create!(title: "Quiz", subject: @subject, due_at: 1.week.from_now, total_points: 10)
    end
  end
end
