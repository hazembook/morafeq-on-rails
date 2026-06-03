class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.string :action
      t.string :auditable_type
      t.integer :auditable_id
      t.references :user, null: false, foreign_key: true
      t.text :record_changes

      t.timestamps
    end
  end
end
