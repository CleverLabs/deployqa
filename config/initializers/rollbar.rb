# frozen_string_literal: true

Rollbar.configure do |config|
  config.access_token = ENV["ROLLBAR_POST_SERVER_ITEM_TOKEN"]
end
