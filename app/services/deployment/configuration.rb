# frozen_string_literal: true

module Deployment
  class Configuration
    include ShallowAttributes

    attribute :application_name, String
    attribute :repo_path, String
    attribute :project_integration_id, String
    attribute :project_integration_type, String
    attribute :env_variables, Hash
    attribute :git_reference, String
    attribute :deployment_configuration_id, Integer
    attribute :application_url, String

    def to_project_instance_configuration
      to_h.slice(:application_name, :deployment_configuration_id, :git_reference, :repo_path, :application_url)
    end

    # Temporary solution
    def add_private_key(private_key)
      self.project_integration_id = private_key
      self
    end
  end
end
