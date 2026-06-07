module Admin
  class EnrollmentsController < BaseController
    before_action :set_subject

    def create
      user = User.find(params[:user_id])
      enrollment = @subject.enrollments.build(user: user)

      if enrollment.save
        log_audit("create", enrollment)
        redirect_to admin_subject_path(@subject), notice: t("flash.admin.enrollment_created")
      else
        redirect_to admin_subject_path(@subject), alert: enrollment.errors.full_messages.to_sentence
      end
    end

    def destroy
      enrollment = @subject.enrollments.find(params[:id])
      changes = enrollment.attributes.except("updated_at", "created_at").to_json
      enrollment.destroy
      log_audit("destroy", enrollment, changes)
      redirect_to admin_subject_path(@subject), notice: t("flash.admin.enrollment_deleted")
    end

    private

    def set_subject
      @subject = Subject.find(params[:subject_id])
    end
  end
end
