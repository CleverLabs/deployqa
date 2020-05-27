# frozen_string_literal: true

Gitlab.configure do |config|
  config.endpoint = Configs::Gitlab.api_endpoint
end
