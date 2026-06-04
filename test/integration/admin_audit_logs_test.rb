require "test_helper"

class AdminAuditLogsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    sign_in_as(@admin)
  end

  test "creating a college logs a create action" do
    assert_difference -> { College.count } => 1, -> { AuditLog.count } => 1 do
      post admin_colleges_path, params: { college: { name: "Faculty of Fine Arts" } }
    end

    college = College.last
    audit_log = AuditLog.last

    assert_equal "create", audit_log.action
    assert_equal "College", audit_log.auditable_type
    assert_equal college.id, audit_log.auditable_id
    assert_equal @admin, audit_log.user
    assert_includes audit_log.record_changes, "Faculty of Fine Arts"
  end

  test "updating a college logs an update action" do
    college = create(:college, name: "Old Name")

    assert_no_difference -> { College.count } do
      assert_difference -> { AuditLog.count } => 1 do
        patch admin_college_path(college), params: { college: { name: "New Name" } }
      end
    end

    audit_log = AuditLog.last
    assert_equal "update", audit_log.action
    assert_equal "College", audit_log.auditable_type
    assert_equal college.id, audit_log.auditable_id
    assert_equal @admin, audit_log.user
    assert_includes audit_log.record_changes, "New Name"
  end

  test "deleting a college logs a destroy action" do
    college = create(:college, name: "To Be Deleted")

    assert_difference -> { College.count } => -1, -> { AuditLog.count } => 1 do
      delete admin_college_path(college)
    end

    audit_log = AuditLog.last
    assert_equal "destroy", audit_log.action
    assert_equal "College", audit_log.auditable_type
    assert_equal college.id, audit_log.auditable_id
    assert_equal @admin, audit_log.user
    assert_includes audit_log.record_changes, "To Be Deleted"
  end
end
