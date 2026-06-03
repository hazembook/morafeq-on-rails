module Admin
  class SubjectsController < BaseController
    before_action :set_subject, only: [ :show, :edit, :update, :destroy ]

    def index
      @subjects = Subject.includes(:department, :teacher).order(:code)
    end

    def show
    end

    def new
      @subject = Subject.new
    end

    def edit
    end

    def create
      @subject = Subject.new(subject_params)
      if @subject.save
        redirect_to admin_subjects_path, notice: "Subject created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @subject.update(subject_params)
        redirect_to admin_subjects_path, notice: "Subject updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @subject.destroy
      redirect_to admin_subjects_path, notice: "Subject deleted."
    end

    private

    def set_subject
      @subject = Subject.find(params[:id])
    end

    def subject_params
      params.require(:subject).permit(:name, :code, :department_id, :teacher_id)
    end
  end
end
