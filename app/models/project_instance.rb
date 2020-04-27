# frozen_string_literal: true

class ProjectInstance < ApplicationRecord
  has_paper_trail

  belongs_to :project
  has_many :build_actions

  validates :deployment_status, :name, presence: true
  validates :configurations, store_model: true
  validates :name, uniqueness: { scope: :project_id }

  enum deployment_status: ProjectInstanceConstants::Statuses::ALL

  attribute :configurations, JSONModels::ProjectInstanceConfiguration.to_array_type
end
