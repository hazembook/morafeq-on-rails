module Admin
  class DepartmentsController < BaseController
    before_action :set_department, only: [ :show, :edit, :update, :destroy ]

    def index
      @departments = Department.includes(:college).order(:name)
    end

    def show
    end

    def new
      @department = Department.new
    end

    def edit
    end

    def create
      @department = Department.new(department_params)
      if @department.save
        log_audit("create", @department)
        redirect_to admin_departments_path, notice: "Department created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @department.update(department_params)
        log_audit("update", @department)
        redirect_to admin_departments_path, notice: "Department updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      changes = @department.attributes.except("updated_at", "created_at").to_json
      @department.destroy
      log_audit("destroy", @department, changes)
      redirect_to admin_departments_path, notice: "Department deleted."
    end

    private

    def set_department
      @department = Department.find(params[:id])
    end

    def department_params
      params.require(:department).permit(:name, :college_id)
    end
  end
end
