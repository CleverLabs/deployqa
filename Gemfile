# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

gem "dotenv-rails", groups: %i[development test]

gem "bootsnap", ">= 1.4.4", require: false
gem "git"
gem "heroku-api-postgres"
gem "jbuilder", "~> 2.5"
gem "lograge", "~> 0.11.1"
gem "logstash-event", "~> 1.2", ">= 1.2.02"
gem "logstash-logger", "~> 0.26.1"
gem "octokit", "~> 4.0"
gem "omniauth"
gem "omniauth-github"
gem "pg"
gem "platform-api"
gem "puma", "~> 3.11"
gem "rails", "~> 5.2.3"
gem "sass-rails", "~> 5.0"
gem "shallow_attributes"
gem "sidekiq"
gem "simple_form"
gem "slim"
gem "sshkey"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"
gem "webpacker", "~> 4.0", ">= 4.0.2"

group :development, :test do
  gem "pry"
  gem "pry-rails"
  gem "standard"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rubocop", "~> 0.71", require: false
  gem "rubocop-rspec", require: false
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 2.15"
  gem "chromedriver-helper"
  gem "rspec-rails", "~> 3.8"
  gem "selenium-webdriver"
  gem "vcr"
  gem "webmock"
end
