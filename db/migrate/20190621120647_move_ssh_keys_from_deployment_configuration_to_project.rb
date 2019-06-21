class MoveSshKeysFromDeploymentConfigurationToProject < ActiveRecord::Migration[5.2]
  def change
    remove_column :deployment_configurations, :private_key, :string
    remove_column :deployment_configurations, :public_key, :string
    add_column :projects, :private_key, :string
    add_column :projects, :public_key, :string
  end
end
