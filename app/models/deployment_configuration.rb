# frozen_string_literal: true

class DeploymentConfiguration < ApplicationRecord
  belongs_to :project
  has_many :project_instances

  validates :name, :repo_path, :status, presence: true

  enum status: DeploymentConfigurationConstants::STATUSES
end
