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
    get feed_path(@post)
    assert_response :success
    assert_select "h3", text: /Comments/
    assert_select "textarea[name='comment[content]']"
  end

  test "should redirect to sign in when unauthenticated" do
    get feed_path(@post)
    assert_redirected_to new_session_path
  end
end
