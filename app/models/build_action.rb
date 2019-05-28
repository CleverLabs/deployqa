# frozen_string_literal: true

class BuildAction < ApplicationRecord
  belongs_to :author, class_name: "User", foreign_key: :author_id
  belongs_to :project_instance
  has_many :build_action_logs

  validates :action, presence: true

  enum action: Constants::BuildAction::ACTIONS
end
