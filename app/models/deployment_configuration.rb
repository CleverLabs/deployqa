# frozen_string_literal: true

class DeploymentConfiguration < ApplicationRecord
  belongs_to :project
  has_many :deployment_configurations_addons, dependent: :destroy
  has_many :addons, through: :deployment_configurations_addons
  has_many :web_processes, inverse_of: :deployment_configuration, dependent: :destroy

  accepts_nested_attributes_for :web_processes, allow_destroy: true

  validates :name, :repo_path, :status, :integration_id, :integration_type, presence: true
  validates :repo_path, uniqueness: { scope: :project_id, message: "already exists within project" }

  enum status: DeploymentConfigurationConstants::STATUSES
  enum integration_type: ProjectsConstants::Providers::ALL
end
