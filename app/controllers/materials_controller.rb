class MaterialsController < ApplicationController
  before_action :set_subject
  before_action :authorize_subject_show, only: [ :index, :show ]
  before_action :require_teacher, only: [ :new, :create, :destroy ]

  def index
    @materials = @subject.materials.order(created_at: :desc)
  end

  def show
    @material = @subject.materials.find(params[:id])
    file = @material.file
    if params[:download]
      send_data file.download, filename: file.filename.to_s, content_type: file.content_type, disposition: :attachment
    else
      safe_type = Material::ALLOWED_TYPES.include?(file.content_type)
      send_data file.download, filename: file.filename.to_s,
        content_type: safe_type ? file.content_type : "application/octet-stream",
        disposition: safe_type ? :inline : :attachment
    end
  end

  def new
    @material = @subject.materials.new
  end

  def create
    @material = @subject.materials.new(material_params)
    if @material.save
      redirect_to subject_materials_path(@subject), notice: t("flash.materials.uploaded")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @material = @subject.materials.find(params[:id])
    @material.destroy
    redirect_to subject_materials_path(@subject), notice: t("flash.materials.removed")
  end

  private

  def set_subject
    @subject = Subject.find(params[:subject_id])
  end

  def require_teacher
    unless Current.user.admin? || @subject.teacher == Current.user
      redirect_to subjects_path, alert: t("common.not_authorized")
    end
  end

  def material_params
    params.require(:material).permit(:title, :file)
  end
end
