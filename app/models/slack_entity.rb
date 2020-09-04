# frozen_string_literal: true

class SlackEntity < ApplicationRecord
  has_paper_trail

  belongs_to :project, optional: false

  validates :project_id, uniqueness: true

  def webhook_url
    data.dig("incoming_webhook", "url")
  end
end
