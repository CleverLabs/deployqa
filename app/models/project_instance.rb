# frozen_string_literal: true

class ProjectInstance < ApplicationRecord
  belongs_to :project
  has_many :build_actions

  validates :deployment_status, :name, presence: true
  validates :configurations, store_model: true

  enum deployment_status: ProjectInstanceConstants::DEPLOYMENT_STATUSES

  attribute :configurations, JSONModels::ProjectInstanceConfiguration.to_array_type
end
