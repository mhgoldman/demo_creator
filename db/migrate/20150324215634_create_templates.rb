class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.integer :skytap_id
      t.string :name
      t.string :region_name

      t.timestamps null: false
    end
  end
end
