# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

gem "dotenv-rails", groups: %i[development test]

gem "aws-sdk-iam"
gem "aws-sdk-ecr"
gem "aws-sdk-s3"
gem "bootsnap", ">= 1.4.4", require: false
gem "enumerize"
gem "flipper"
gem "flipper-active_record"
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
gem "octokit"
gem "omniauth"
gem "omniauth-github"
gem "omniauth-gitlab"
gem "omniauth-rails_csrf_protection", "~> 0.1.2" # Remove after https://github.com/omniauth/omniauth/pull/809 will be resolved
gem "paper_trail"
gem "pg"
gem "platform-api"
gem "puma", "~> 3.12"
gem "pundit", "~> 2.0", ">= 2.0.1"
gem "rails", "~> 5.2.3"
gem "redis-rails"
gem "rendezvous"
gem "rollbar"
gem "shallow_attributes"
gem "sidekiq"
gem "simple_form"
gem "slim"
gem "sshkey"
gem "store_model"
gem "strong_migrations"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"
gem "webpacker", "~> 4.0", ">= 4.0.2"

gem "nomad", "~> 0.1", require: false

group :development, :test do
  gem "pry"
  gem "pry-rails"
  gem "standard"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rubocop", "~> 0.71", require: false
  gem "rubocop-rspec", require: false
  gem "seed-fu"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "chromedriver-helper"
  gem "rspec-rails", "~> 3.8"
  gem "selenium-webdriver"
  gem "vcr"
  gem "webmock"
end
