# frozen_string_literal: true

class BuildActionLog < ApplicationRecord
  belongs_to :build_action, required: true

  validates :message, :status, presence: true

  enum status: Constants::BuildAction::Log::STATUSES
end
