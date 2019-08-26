class RenameDeploymentConfigurationIdInWebProcesses < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      rename_column :web_processes, :deployment_configuration_id, :repository_id
      remove_foreign_key :web_processes, :deployment_configurations
      add_foreign_key :web_processes, :repositories
    end
  end

  def down
    safety_assured do
      rename_column :web_processes, :repository_id, :deployment_configuration_id
      remove_foreign_key :web_processes, :repositories
      add_foreign_key :web_processes, :deployment_configurations
    end
  end
end
