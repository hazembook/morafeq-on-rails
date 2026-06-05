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

  test "mark_read with JSON returns correct replacement HTML" do
    sign_in_as(@student)
    assert_difference -> { PostView.count } do
      post mark_read_feed_path(@post), headers: { Accept: "application/json" }
    end
    assert_response :success
    body = response.parsed_body
    assert body["success"]
    assert_includes body["html"], "svg"
    assert_includes body["html"], "feed.read"
    assert_not_includes body["html"], "mark_read"
  end

  test "mark_read with HTML redirects to feed" do
    sign_in_as(@student)
    post mark_read_feed_path(@post), headers: { Accept: "text/html" }
    assert_redirected_to feed_index_path
  end

  test "mark_read does not create PostView for author" do
    teacher = create(:user, :teacher)
    subject = create(:subject, teacher: teacher)
    post = create(:post, author: teacher, scope: subject)
    sign_in_as(teacher)
    assert_no_difference -> { PostView.count } do
      post mark_read_feed_path(post), headers: { Accept: "application/json" }
    end
    assert_response :success
    body = response.parsed_body
    assert_equal "", body["html"].strip
  end

  test "mark_read with Turbo Stream returns turbo-stream content" do
    sign_in_as(@student)
    post mark_read_feed_path(@post), headers: { Accept: "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_includes response.body, "turbo-stream"
    assert_includes response.body, "read_status_post_#{@post.id}"
  end
end
