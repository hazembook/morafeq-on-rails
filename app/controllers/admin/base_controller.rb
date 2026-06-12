module Admin
  class BaseController < ApplicationController
    before_action :require_admin
    before_action :restrict_demo, if: -> { action_name.in?(%w[create update destroy]) }

    private

    def require_admin
      redirect_to root_path, alert: t("common.not_authorized") unless Current.user&.admin?
    end

    def restrict_demo
      redirect_to request.referer || admin_root_path, alert: t("flash.admin.demo_restricted") if Rails.env.demo?
    end

    def log_audit(action, auditable, changes = nil)
      return unless Current.user
      AuditLog.create!(
        action: action,
        auditable_type: auditable.class.name,
        auditable_id: auditable.id,
        user: Current.user,
        record_changes: changes || auditable.saved_changes.except("updated_at", "created_at", "password_digest").to_json
      )
    end
  end
end
