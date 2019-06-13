class AddStatusToDeploymentConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :deployment_configurations, :status, :integer
  end
end
