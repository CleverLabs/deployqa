# frozen_string_literal: true

require "configs/gitlab"

Gitlab.configure do |config|
  config.endpoint = Configs::Gitlab.api_endpoint
end
