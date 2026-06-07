require "test_helper"

class AdminTaskDistributionsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @teacher = create(:user, :teacher)
    sign_in_as(@admin)
  end

  test "index shows task distributions" do
    create(:task_distribution, assigner: @admin, assignee: @teacher)
    get admin_task_distributions_path
    assert_response :success
  end

  test "new renders form" do
    get new_admin_task_distribution_path
    assert_response :success
  end

  test "creating a task distribution logs an audit" do
    assert_difference -> { TaskDistribution.count } => 1, -> { AuditLog.count } => 1 do
      post admin_task_distributions_path, params: {
        task_distribution: {
          assignee_id: @teacher.id,
          manage_posts: "1",
          manage_materials: "1"
        }
      }
    end

    td = TaskDistribution.last
    assert_equal @admin, td.assigner
    assert_equal @teacher, td.assignee
    assert td.manage_posts
    assert td.manage_materials
    assert_not td.manage_quizzes

    assert_redirected_to admin_task_distributions_path
    assert_match I18n.t("flash.admin.task_distribution_created"), flash[:notice]

    audit_log = AuditLog.last
    assert_equal "create", audit_log.action
    assert_equal "TaskDistribution", audit_log.auditable_type
  end

  test "updating a task distribution logs an audit" do
    td = create(:task_distribution, assigner: @admin, assignee: @teacher, manage_posts: false)

    assert_no_difference -> { TaskDistribution.count } do
      assert_difference -> { AuditLog.count } => 1 do
        patch admin_task_distribution_path(td), params: {
          task_distribution: { manage_posts: "1" }
        }
      end
    end

    assert td.reload.manage_posts
    assert_redirected_to admin_task_distributions_path
    assert_match I18n.t("flash.admin.task_distribution_updated"), flash[:notice]
  end

  test "deleting a task distribution logs an audit" do
    td = create(:task_distribution, assigner: @admin, assignee: @teacher)

    assert_difference -> { TaskDistribution.count } => -1, -> { AuditLog.count } => 1 do
      delete admin_task_distribution_path(td)
    end

    assert_redirected_to admin_task_distributions_path
    assert_match I18n.t("flash.admin.task_distribution_deleted"), flash[:notice]
  end

  test "non-admin cannot manage task distributions" do
    sign_out
    sign_in_as(@teacher)

    get admin_task_distributions_path
    assert_redirected_to root_path

    post admin_task_distributions_path, params: { task_distribution: { assignee_id: @teacher.id } }
    assert_redirected_to root_path
  end

  test "creating with scope type and id" do
    college = create(:college)

    post admin_task_distributions_path, params: {
      task_distribution: {
        assignee_id: @teacher.id,
        scope_type: "College",
        scope_id: college.id,
        manage_enrollments: "1"
      }
    }

    td = TaskDistribution.last
    assert_equal college, td.scope
    assert_equal "College", td.scope_type
    assert td.manage_enrollments
  end

  test "show displays flags" do
    td = create(:task_distribution, assigner: @admin, assignee: @teacher, manage_posts: true, manage_quizzes: true)
    get admin_task_distribution_path(td)
    assert_response :success
    assert_match I18n.t("admin.task_distributions.flags.manage_posts"), response.body
    assert_match I18n.t("admin.task_distributions.flags.manage_quizzes"), response.body
  end
end
