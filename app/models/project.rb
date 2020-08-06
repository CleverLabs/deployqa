# frozen_string_literal: true

class Project < ApplicationRecord
  has_paper_trail

  has_many :repositories, dependent: :destroy
  has_many :project_instances, dependent: :destroy
  has_many :project_user_roles, dependent: :destroy
  has_many :users, through: :project_user_roles
  has_many :invoices, dependent: :destroy
  has_one :slack_entity, dependent: :destroy
  has_one :gitlab_repositories_info, dependent: :destroy

  validates :name, :integration_id, :integration_type, presence: true

  enum integration_type: ProjectsConstants::Providers::ALL
end
