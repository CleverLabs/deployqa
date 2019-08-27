# frozen_string_literal: true

module JSONModels
  class ProjectInstanceConfiguration
    include StoreModel::Model

    attribute :application_name, :string
    attribute :env_variables
    attribute :deployment_configuration_id, :integer # TODO: Delete after migrate it to repository_id
    attribute :repository_id, :integer
    attribute :application_url, :string
    attribute :repo_path, :string
    attribute :git_reference, :string
    attribute :web_processes
    attribute :addons

    validates :application_name, :repository_id, :application_url, :repo_path, :git_reference, presence: true
  end
end
