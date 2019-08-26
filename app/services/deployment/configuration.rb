# frozen_string_literal: true

module Deployment
  class Configuration
    include ShallowAttributes

    attribute :application_name, String
    attribute :env_variables, Hash
    attribute :repository_id, Integer
    attribute :application_url, String
    attribute :addons, Array, of: Deployment::Addon
    attribute :web_processes, Array, of: Deployment::WebProcess
    attribute :repo_configuration, Deployment::RepoConfiguration

    def to_project_instance_configuration
      to_h.slice(:application_name, :repository_id, :application_url, :env_variables, :web_processes, :addons)
          .merge(repo_configuration.to_h.slice(:git_reference, :repo_path))
    end

    # Temporary solution
    def add_private_key(private_key)
      return self unless repo_configuration.project_integration_type == ProjectsConstants::Providers::VIA_SSH

      repo_configuration.project_integration_id = private_key
      self
    end
  end
end
