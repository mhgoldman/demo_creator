class AddProvisioningStatusToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :provisioning_status_name, :string
  end
end
