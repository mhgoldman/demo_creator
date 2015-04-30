class CreateRequestors < ActiveRecord::Migration
  def change
    create_table :requestors do |t|
      t.string :email
      t.string :skytap_url

      t.timestamps null: false
    end

    add_index :requestors, :email, unique: true
  end
end
