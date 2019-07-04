# frozen_string_literal: true

module Slack
  class Notificator
    def initialize(project_instance)
      @project_instance = project_instance
    end

    def send_message(text)
      HTTParty.post(@project_instance.project.slack_entity.webhook_url,
                    body: { text: text }.to_json,
                    headers: { "Content-Type" => "application/json" })
    end
  end
end
