class AddIndexOnAuditableToAuditLogs < ActiveRecord::Migration[8.1]
  def change
    add_index :audit_logs, [ :auditable_type, :auditable_id ]
  end
end
