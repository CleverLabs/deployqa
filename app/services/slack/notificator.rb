# frozen_string_literal: true

module Slack
  class Notificator
    def initialize(project)
      @project = project
    end

    def send_message(text)
      return if @project.slack_entity.blank?

      HTTParty.post(@project.slack_entity.webhook_url,
                    body: { text: text }.to_json,
                    headers: { "Content-Type" => "application/json" })
    end
  end
end
