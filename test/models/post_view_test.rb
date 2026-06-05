require "test_helper"

class PostViewTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @subject = create(:subject, teacher: @teacher)
    @post = create(:post, author: @teacher, scope: @subject)
  end

  test "creates view with valid attributes" do
    user = create(:user)
    pv = PostView.new(post: @post, user: user)
    assert pv.valid?
  end

  test "validates uniqueness of user per post" do
    user = create(:user)
    PostView.create!(post: @post, user: user)
    duplicate = PostView.new(post: @post, user: user)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "belongs to post" do
    user = create(:user)
    pv = PostView.create!(post: @post, user: user)
    assert_equal @post, pv.post
  end

  test "belongs to user" do
    user = create(:user)
    pv = PostView.create!(post: @post, user: user)
    assert_equal user, pv.user
  end

  test "counter cache increments on post" do
    user = create(:user)
    assert_difference -> { @post.reload.post_views_count.to_i } do
      PostView.create!(post: @post, user: user)
    end
  end

  test "counter cache handles multiple views" do
    users = create_list(:user, 3)
    assert_difference -> { @post.reload.post_views_count.to_i }, 3 do
      users.each { |u| PostView.create!(post: @post, user: u) }
    end
  end
end
