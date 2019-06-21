# frozen_string_literal: true

class Project < ApplicationRecord
  has_many :deployment_configurations
  has_many :project_instances
  has_many :project_user_roles, dependent: :destroy
  has_many :users, through: :project_user_roles

  validates :name, :integration_id, :integration_type, presence: true

  enum integration_type: ProjectsConstants::Providers::ALL
end
