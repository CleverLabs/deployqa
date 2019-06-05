# frozen_string_literal: true

module Deployment
  class Configuration
    include ShallowAttributes

    attribute :application_name, String
    attribute :repo_path, String
    attribute :private_key, String
    attribute :env_variables, Hash
    attribute :git_reference, String
    attribute :deployment_configuration_id, Integer

    def to_project_instance_configuration
      to_h.slice(:application_name, :deployment_configuration_id, :git_reference, :repo_path)
    end
  end
end
