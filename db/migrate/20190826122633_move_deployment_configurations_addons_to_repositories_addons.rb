class MoveDeploymentConfigurationsAddonsToRepositoriesAddons < ActiveRecord::Migration[5.2]
  RepositoriesAddon = Class.new(ActiveRecord::Base)
  DeploymentConfigurationsAddon = Class.new(ActiveRecord::Base)

  def up
    DeploymentConfigurationsAddon.find_each do |pair|
      RepositoriesAddon.create!(pair.attributes)
      pair.destroy!
    end
  end

  def down
    RepositoriesAddon.find_each do |pair|
      DeploymentConfigurationsAddon.create!(pair.attributes)
      pair.destroy!
    end
  end
end
