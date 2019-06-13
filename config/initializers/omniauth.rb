# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"],
           redirect_uri: "http://localhost:3000/", state: SecureRandom.uuid # TODO: change state to something meaningful
end
