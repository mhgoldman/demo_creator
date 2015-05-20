class AddProvisioningErrorToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :provisioning_error, :string
  end
end
