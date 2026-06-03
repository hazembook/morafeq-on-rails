require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "validates presence of email_address" do
    user = build(:user, email_address: nil)
    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
  end

  test "validates uniqueness of email_address" do
    create(:user, email_address: "test@example.com")
    user = build(:user, email_address: "test@example.com")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "validates presence of full_name" do
    user = build(:user, full_name: nil)
    assert_not user.valid?
    assert_includes user.errors[:full_name], "can't be blank"
  end

  test "has_many sessions with dependent destroy" do
    user = create(:user)
    session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test")
    assert_equal 1, user.sessions.count
    user.destroy
    assert_raises(ActiveRecord::RecordNotFound) { session.reload }
  end

  test "has_one_attached avatar" do
    assert_respond_to User.new, :avatar
  end

  test "defines role enum with correct values" do
    assert_equal 0, User.roles[:student]
    assert_equal 1, User.roles[:teacher]
    assert_equal 2, User.roles[:admin]
  end

  test "default role is student" do
    user = User.new
    assert user.student?
  end

  test "has_secure_password" do
    assert_respond_to User.new, :authenticate
  end

  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "factory creates valid user" do
    user = build(:user)
    assert user.valid?
  end

  test "factory creates teacher" do
    user = build(:user, :teacher)
    assert user.teacher?
  end

  test "factory creates admin" do
    user = build(:user, :admin)
    assert user.admin?
  end
end
