# frozen_string_literal: true

class BuildAction < ApplicationRecord
  has_paper_trail

  belongs_to :author, class_name: "UserReference", foreign_key: :author_id
  belongs_to :project_instance
  has_many :build_action_logs

  validates :action, presence: true

  enum action: BuildActionConstants::ACTIONS
  enum status: BuildActionConstants::Statuses::ALL

  attribute :configurations, JsonModels::ProjectInstanceConfiguration.to_array_type
end
