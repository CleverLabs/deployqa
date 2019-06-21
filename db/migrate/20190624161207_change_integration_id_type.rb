class ChangeIntegrationIdType < ActiveRecord::Migration[5.2]
  def up
    change_column :deployment_configurations, :integration_type, "integer USING integration_type::integer"
    change_column :projects, :integration_type, "integer USING integration_type::integer"
  end
end
