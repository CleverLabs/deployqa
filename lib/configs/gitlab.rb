# frozen_string_literal: true

module Configs
  class Gitlab
    class << self
      def app_id
        ENV.fetch("GITLAB_APP_ID")
      end

      def app_secret
        ENV.fetch("GITLAB_APP_SECRET")
      end

      def redirect_uri
        ENV.fetch("GITLAB_REDIRECT_URI")
      end

      def api_endpoint
        ENV["GITLAB_API_ENDPOINT"] || "https://gitlab.com/api/v4"
      end

      def webhook_url
        ENV.fetch("GITLAB_WEBHOOK_URL")
      end

      def webhook_secret
        ENV.fetch("GITLAB_WEBHOOK_SECRET")
      end

      def deployqa_bot_id
        ENV.fetch("GITLAB_DEPLOYQA_BOT_ID")
      end

      def deployqa_bot_token
        ENV.fetch("GITLAB_DEPLOYQA_BOT_TOKEN")
      end

      def webhook_integrations_url
        ENV["GITLAB_WEBHOOK_URL"] || Rails.application.routes.url_helpers.webhooks_gitlab_integrations_url
      end
    end
  end
end
