# frozen_string_literal: true

module OmniauthConstants
  PROVIDERS = [
    GITHUB = "github",
    GITLAB = "gitlab",
    SLACK = "slack"
  ].freeze

  LOGIN_PROVIDERS = [GITHUB, GITLAB].freeze
end
