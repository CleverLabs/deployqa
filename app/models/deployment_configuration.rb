# frozen_string_literal: true

class DeploymentConfiguration < ApplicationRecord
  belongs_to :project
  has_many :project_instances

  validates :name, :repo_path, :status, :integration_id, :integration_type, presence: true
  validates :repo_path, uniqueness: { scope: :project_id, message: "already exists within project" }

  enum status: DeploymentConfigurationConstants::STATUSES
  enum integration_type: ProjectsConstants::Providers::ALL
end
