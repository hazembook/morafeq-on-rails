module Admin
  class BaseController < ApplicationController
    before_action :require_admin

    private

    def require_admin
      redirect_to root_path, alert: t("common.not_authorized") unless Current.user&.admin?
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
