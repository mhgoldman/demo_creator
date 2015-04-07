class CreateDemos < ActiveRecord::Migration
  def change
    create_table :demos do |t|
      t.integer :template_id
      t.string :description
      t.integer :requestor_id
      t.integer :status
      t.string :token
      t.string :published_url
      t.datetime :confirmation_expiration
      t.datetime :usage_expiration
      t.integer :skytap_id
      t.timestamps null: false
    end
  end
end
