# frozen_string_literal: true

class DeploymentConfigurationForm
  include ShallowAttributes

  attribute :repo_path, String
  attribute :env_variables, Hash
  attribute :name, String, default: ->(form, _attribute) { form.repo_path.split(":").last.gsub(/\.git$/, "") }
  attribute :status, String, default: DeploymentConfigurationConstants::ACTIVE
  attribute :integration_type, String, default: ProjectsConstants::Providers::VIA_SSH
  attribute :integration_id, String, default: ->(_, _) { SecureRandom.uuid }
  attribute :project, Project

  alias _env_variables= env_variables=

  def env_variables=(value)
    self._env_variables = Hash[value.split("\n").map { |line| line.tr("\r", "").split(": ") }]
  end
end
