module Admin
  class TaskDistributionsController < BaseController
    before_action :set_task_distribution, only: [ :show, :edit, :update, :destroy ]

    def index
      @task_distributions = TaskDistribution.includes(:assigner, :assignee).order(created_at: :desc)
    end

    def show
    end

    def new
      @task_distribution = TaskDistribution.new
    end

    def edit
    end

    def create
      @task_distribution = TaskDistribution.new(task_distribution_params)
      @task_distribution.assigner = Current.user

      if @task_distribution.save
        log_audit("create", @task_distribution)
        redirect_to admin_task_distributions_path, notice: t("flash.admin.task_distribution_created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @task_distribution.update(task_distribution_params)
        log_audit("update", @task_distribution)
        redirect_to admin_task_distributions_path, notice: t("flash.admin.task_distribution_updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      changes = @task_distribution.attributes.except("updated_at", "created_at").to_json
      @task_distribution.destroy
      log_audit("destroy", @task_distribution, changes)
      redirect_to admin_task_distributions_path, notice: t("flash.admin.task_distribution_deleted")
    end

    private

    FLAG_FIELDS = %i[
      manage_posts manage_materials manage_quizzes manage_schedules
      manage_attendance manage_chat manage_enrollments manage_prerequisites
      manage_exam_grades manage_subjects manage_departments
    ].freeze

    def set_task_distribution
      @task_distribution = TaskDistribution.find(params[:id])
    end

    def task_distribution_params
      params.require(:task_distribution).permit(:assignee_id, :scope_type, :scope_id, *FLAG_FIELDS)
    end
  end
end
