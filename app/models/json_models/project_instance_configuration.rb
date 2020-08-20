# frozen_string_literal: true

module JsonModels
  class ProjectInstanceConfiguration
    include StoreModel::Model

    attribute :application_name, :string
    attribute :env_variables
    attribute :repository_id, :integer
    attribute :application_url, :string
    attribute :repo_path, :string
    attribute :git_reference, :string
    attribute :web_processes
    attribute :addons
    attribute :build_configuration

    validates :application_name, :repository_id, :application_url, :repo_path, :git_reference, presence: true
  end
end
