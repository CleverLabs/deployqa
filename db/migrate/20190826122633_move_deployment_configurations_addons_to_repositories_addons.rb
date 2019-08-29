class MoveDeploymentConfigurationsAddonsToRepositoriesAddons < ActiveRecord::Migration[5.2]
  RepositoriesAddon = Class.new(ActiveRecord::Base)
  DeploymentConfigurationsAddon = Class.new(ActiveRecord::Base)

  def up
    DeploymentConfigurationsAddon.find_each do |pair|
      new_attributes = pair.attributes.except("deployment_configuration_id")
      new_attributes["repository_id"] = pair.deployment_configuration_id

      RepositoriesAddon.create!(new_attributes)
    end
  end

  def down
    RepositoriesAddon.find_each do |pair|
      new_attributes = pair.attributes.except("repository_id")
      new_attributes["deployment_configuration_id"] = pair.repository_id

      DeploymentConfigurationsAddon.create!(new_attributes)
    end
  end
end
