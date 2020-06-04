# frozen_string_literal: true

module OmniauthConstants
  PROVIDERS = [
    GITHUB = "github",
    GITLAB = "gitlab",
    SLACK = "slack",
    NO_PROVIDER = "no_provider"
  ].freeze

  LOGIN_PROVIDERS = [GITHUB, GITLAB, NO_PROVIDER].freeze
end
