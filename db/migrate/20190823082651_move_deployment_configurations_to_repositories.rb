class MoveDeploymentConfigurationsToRepositories < ActiveRecord::Migration[5.2]
  DeploymentConfiguration = Class.new(ActiveRecord::Base)
  Repository = Class.new(ActiveRecord::Base)

  def up
    DeploymentConfiguration.find_each do |deployment_configuration|
      attributes = deployment_configuration.attributes.except("repo_path")
      attributes["path"] = deployment_configuration.repo_path

      Repository.create!(attributes)
      deployment_configuration.destroy!
    end
  end

  def down
    Repository.find_each do |repository|
      attributes = repository.attributes.except("path")
      attributes["repo_path"] = repository.path

      DeploymentConfiguration.create!(attributes)
      repository.destroy!
    end
  end
end
