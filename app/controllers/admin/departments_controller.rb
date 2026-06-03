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
        redirect_to admin_departments_path, notice: "Department created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @department.update(department_params)
        redirect_to admin_departments_path, notice: "Department updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @department.destroy
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
