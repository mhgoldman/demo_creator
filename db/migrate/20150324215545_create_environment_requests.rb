class CreateEnvironmentRequests < ActiveRecord::Migration
  def change
    create_table :environment_requests do |t|
      t.integer :template_id
      t.string :description
      t.integer :requestor_id
      t.boolean :confirmed
      t.string :status
      t.string :token
      t.string :published_url
      t.datetime :confirmation_expiration
      t.datetime :usage_expiration

      t.timestamps null: false
    end
  end
end
