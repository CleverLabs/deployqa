# frozen_string_literal: true

class DeploymentConfigurationStatus
  def initialize(project)
    @project = project
  end

  def active?(repo_path)
    @project.deployment_configurations.find_by(repo_path: repo_path).status == DeploymentConfigurationConstants::ACTIVE
  end
end
