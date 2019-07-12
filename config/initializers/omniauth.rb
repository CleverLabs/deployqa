# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"],
           redirect_uri: ENV["GITHUB_APP_REDIRECT_URI"], state: SecureRandom.uuid # TODO: change state to something meaningful

  provider :slack, ENV["SLACK_CLIENT_ID"], ENV["SLACK_CLIENT_SECRET"], scope: "incoming-webhook",
           redirect_uri: ENV["SLACK_REDIRECT_URI"]
end

OmniAuth.config.allowed_request_methods = [:post]
