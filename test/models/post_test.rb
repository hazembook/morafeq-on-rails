require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @college = create(:college)
    @department = create(:department, college: @college)
    @teacher = create(:user, :teacher)
    @subject = create(:subject, department: @department, teacher: @teacher)
    @student = create(:user)
    create(:enrollment, user: @student, subject: @subject)
  end

  test "validates presence of content" do
    post = Post.new(content: nil, author: @teacher, scope: @subject, scope_type: "Subject", scope_id: @subject.id)
    assert_not post.valid?
    assert_includes post.errors[:content], "can't be blank"
  end

  test "accepts valid scope_types" do
    post = build(:post, author: @teacher, scope: @subject)
    assert post.valid?
  end

  test "belongs to author" do
    post = create(:post, author: @teacher, scope: @subject)
    assert_equal @teacher, post.author
  end

  test "belongs to scope polymorphically" do
    post = create(:post, author: @teacher, scope: @subject)
    assert_equal @subject, post.scope
  end

  test "student sees posts in enrolled subject" do
    post = create(:post, author: @teacher, scope: @subject)
    assert_includes Post.feed_for(@student), post
  end

  test "student does not see posts in unenrolled subject" do
    other_subject = create(:subject, code: "OTHER999")
    post = create(:post, author: @teacher, scope: other_subject)
    assert_not_includes Post.feed_for(@student), post
  end

  test "student sees posts in department of enrolled subject" do
    post = create(:post, author: @teacher, scope: @department, scope_type: "Department", scope_id: @department.id)
    assert_includes Post.feed_for(@student), post
  end

  test "student sees posts in college of enrolled subject" do
    post = create(:post, author: @teacher, scope: @college, scope_type: "College", scope_id: @college.id)
    assert_includes Post.feed_for(@student), post
  end

  test "teacher sees posts in their taught subjects" do
    post = create(:post, author: @teacher, scope: @subject)
    assert_includes Post.feed_for(@teacher), post
  end

  test "admin sees all posts" do
    admin = create(:user, :admin)
    post1 = create(:post, author: @teacher, scope: @subject)
    other = create(:subject, code: "UNREL99")
    post2 = create(:post, author: @teacher, scope: other)
    feed = Post.feed_for(admin)
    assert_includes feed, post1
    assert_includes feed, post2
  end

  test "destroy hard-deletes post" do
    post = create(:post, author: @teacher, scope: @subject)
    post.destroy
    assert_not Post.exists?(post.id)
  end

  test "destroy hard-deletes comments" do
    post = create(:post, author: @teacher, scope: @subject)
    comment = create(:comment, post: post, user: @student, content: "Nice post!")
    post.destroy
    assert_not Comment.exists?(comment.id)
  end
end
