class MaterialsController < ApplicationController
  before_action :set_subject
  before_action :require_teacher, only: [ :new, :create, :destroy ]

  def index
    @materials = @subject.materials.kept.order(created_at: :desc)
  end

  def show
    @material = @subject.materials.kept.find(params[:id])
    send_file @material.file.download, filename: @material.file.filename.to_s, content_type: @material.file.content_type
  end

  def new
    @material = @subject.materials.new
  end

  def create
    @material = @subject.materials.new(material_params)
    if @material.save
      redirect_to subject_materials_path(@subject), notice: "Material uploaded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @material = @subject.materials.kept.find(params[:id])
    @material.discard
    redirect_to subject_materials_path(@subject), notice: "Material removed."
  end

  private

  def set_subject
    @subject = Subject.find(params[:subject_id])
  end

  def require_teacher
    unless Current.user.admin? || @subject.teacher == Current.user
      redirect_to subjects_path, alert: "Not authorized."
    end
  end

  def material_params
    params.require(:material).permit(:title, :file)
  end
end
