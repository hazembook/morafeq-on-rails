require "test_helper"

class FeedControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, role: :student)
    @subject = create(:subject)
    create(:enrollment, user: @student, subject: @subject)
    @post = create(:post, scope: @subject)
  end

  test "should get show when authenticated" do
    sign_in_as(@student)
    @post.update!(comments_disabled: false)
    get feed_path(@post)
    assert_response :success
    assert_select "h3", text: /Comments/
    assert_select "textarea[name='comment[content]']"
  end

  test "should redirect to sign in when unauthenticated" do
    get feed_path(@post)
    assert_redirected_to new_session_path
  end

  test "mark_read creates PostView and returns read_status frame" do
    sign_in_as(@student)
    assert_difference -> { PostView.count } do
      post mark_read_feed_path(@post)
    end
    assert_response :ok
    assert_match "read_status_post_#{@post.id}", response.body
  end

  test "mark_read does not create PostView for author" do
    teacher = create(:user, :teacher)
    subject = create(:subject, teacher: teacher)
    post = create(:post, author: teacher, scope: subject)
    sign_in_as(teacher)
    assert_no_difference -> { PostView.count } do
      post mark_read_feed_path(post)
    end
    assert_response :ok
  end
end
