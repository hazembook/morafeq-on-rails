class CreateDepartments < ActiveRecord::Migration[8.1]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.references :college, null: false, foreign_key: true

      t.timestamps
    end
  end
end
