class AddIntegrationIdIntegrationTypeToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :integration_id, :string
    add_column :projects, :integration_type, :string
  end
end
