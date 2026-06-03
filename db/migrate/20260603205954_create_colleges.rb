class CreateColleges < ActiveRecord::Migration[8.1]
  def change
    create_table :colleges do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :colleges, :name, unique: true
  end
end
