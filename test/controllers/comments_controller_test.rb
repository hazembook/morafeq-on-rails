require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, role: :student)
    @subject = create(:subject)
    create(:enrollment, user: @student, subject: @subject)
    @post = create(:post, scope: @subject)
  end

  test "should create comment when authenticated" do
    sign_in_as(@student)
    assert_difference -> { @post.comments.count }, 1 do
      post feed_comments_path(@post), params: { comment: { content: "This is a test comment." } }
    end
    assert_redirected_to feed_path(@post)
    follow_redirect!
    assert_match "Comment added successfully", response.body
  end

  test "should not create comment when unauthenticated" do
    assert_no_difference -> { @post.comments.count } do
      post feed_comments_path(@post), params: { comment: { content: "This is a test comment." } }
    end
    assert_redirected_to new_session_path
  end
end
