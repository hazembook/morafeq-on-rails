module Admin
  class AuditLogsController < BaseController
    def index
      @audit_logs = AuditLog.includes(:user).order(created_at: :desc).limit(100)
    end

    def show
      @audit_log = AuditLog.find(params[:id])
    end
  end
end
