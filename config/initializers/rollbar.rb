# frozen_string_literal: true

Rollbar.configure do |config|
  config.access_token = ENV["ROLLBAR_POST_SERVER_ITEM_TOKEN"]
  config.code_version = Git.open(".").object("HEAD").sha

  config.before_process = proc do |options|
    raise Rollbar::Ignore if options[:exception].is_a?(ActionController::RoutingError)
  end
end
