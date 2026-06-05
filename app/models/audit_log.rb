class AuditLog < ApplicationRecord
  belongs_to :user, inverse_of: :audit_logs
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true
end
