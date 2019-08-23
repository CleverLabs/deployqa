class MoveDeploymentConfigurationsToRepositories < ActiveRecord::Migration[5.2]
  DeploymentConfiguration = Class.new(ActiveRecord::Base)
  Repository = Class.new(ActiveRecord::Base)

  def change
    DeploymentConfiguration.find_each do |deployment_configuration|
      attributes = deployment_configuration.attributes.except("repo_path")
      attributes["path"] = deployment_configuration.repo_path

      Repository.create!(attributes)
    end
  end
end
