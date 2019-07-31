# frozen_string_literal: true

class Project < ApplicationRecord
  has_paper_trail

  has_many :deployment_configurations, dependent: :destroy
  has_many :project_instances, dependent: :destroy
  has_many :project_user_roles, dependent: :destroy
  has_many :users, through: :project_user_roles
  has_one :slack_entity, dependent: :destroy

  validates :name, :integration_id, :integration_type, presence: true

  enum integration_type: ProjectsConstants::Providers::ALL
end
