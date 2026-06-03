class CreateMaterials < ActiveRecord::Migration[8.1]
  def change
    create_table :materials do |t|
      t.string :title, null: false
      t.references :subject, null: false, foreign_key: true
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :materials, :discarded_at
  end
end
