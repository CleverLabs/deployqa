class AddIntegrationIdIntegrationTypeToDeploymentConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :deployment_configurations, :integration_id, :string
    add_column :deployment_configurations, :integration_type, :string
  end
end
