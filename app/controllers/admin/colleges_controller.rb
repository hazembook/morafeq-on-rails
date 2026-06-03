module Admin
  class CollegesController < BaseController
    before_action :set_college, only: [ :show, :edit, :update, :destroy ]

    def index
      @colleges = College.order(:name)
    end

    def show
    end

    def new
      @college = College.new
    end

    def edit
    end

    def create
      @college = College.new(college_params)
      if @college.save
        redirect_to admin_colleges_path, notice: "College created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @college.update(college_params)
        redirect_to admin_colleges_path, notice: "College updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @college.destroy
      redirect_to admin_colleges_path, notice: "College deleted."
    end

    private

    def set_college
      @college = College.find(params[:id])
    end

    def college_params
      params.require(:college).permit(:name)
    end
  end
end
