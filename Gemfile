# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.1"

gem "dotenv-rails", groups: %i[development test]

gem "actionpack-action_caching"
gem "actionpack-page_caching"
gem "aws-sdk-ecr"
gem "aws-sdk-iam"
gem "aws-sdk-s3"
gem "bootsnap", ">= 1.4.8", require: false
gem "ddtrace"
gem "doorkeeper", "~> 5.4.0"
gem "enumerize"
gem "flipper"
gem "flipper-active_record", "~> 0.18.0"
gem "flipper-ui"
gem "ginjo-omniauth-slack", require: "omniauth-slack"
gem "git"
gem "gitlab", "~> 4.12"
gem "good_migrations"
gem "heroku-api-postgres"
gem "httparty"
gem "lograge", "~> 0.11.1"
gem "logstash-event", "~> 1.2", ">= 1.2.02"
gem "logstash-logger", "~> 0.26.1"
gem "nomad", require: false, git: "https://github.com/CleverLabs/nomad-ruby.git", branch: "master"
gem "octokit"
gem "omniauth", "~> 1.9.1"
gem "omniauth-github"
gem "omniauth-gitlab"
gem "omniauth-rails_csrf_protection", "~> 0.1.2" # Remove after https://github.com/omniauth/omniauth/pull/809 will be resolved
gem "paper_trail"
gem "pg"
gem "platform-api"
gem "puma", "~> 3.12"
gem "pundit", "~> 2.0", ">= 2.0.1"
gem "rails", "~> 6.0.3.3"
gem "react_on_rails"
gem "redis-mutex"
gem "redis-rails"
gem "rendezvous"
gem "rollbar"
gem "shallow_attributes"
gem "sidekiq"
gem "sidekiq-cron", "~> 1.2"
gem "sidekiq-statistic"
gem "simple_form"
gem "slim"
gem "sshkey"
gem "store_model"
gem "strong_migrations"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"
gem "webpacker"

group :development, :test do
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "standard"
end

group :development do
  gem "listen", "~> 3.2.0"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "seed-fu"
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "capybara"
  gem "database_cleaner-active_record"
  gem "factory_bot"
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "simplecov"
  gem "vcr"
  gem "webdrivers"
  gem "webmock"
end
