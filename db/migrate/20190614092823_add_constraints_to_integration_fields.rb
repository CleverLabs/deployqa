class AddConstraintsToIntegrationFields < ActiveRecord::Migration[5.2]
  def change
    change_column_null :projects, :integration_id, false
    change_column_null :projects, :integration_type, false
    add_index :projects, [:integration_id, :integration_type], unique: true

    change_column_null :deployment_configurations, :integration_id, false
    change_column_null :deployment_configurations, :integration_type, false
    change_column_null :deployment_configurations, :status, false
    add_index :deployment_configurations, [:integration_id, :integration_type], unique: true, name: "index_deployment_configurations_on_integrations"
  end
end
