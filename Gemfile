# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.1"

gem "dotenv-rails", groups: %i[development test]

gem "puma", "~> 3.11"
gem "rails", "~> 5.2.3"
gem "sass-rails", "~> 5.0"
gem "sqlite3"
gem "uglifier", ">= 1.3.0"

gem "jbuilder", "~> 2.5"
gem "slim"
gem "turbolinks", "~> 5"
gem "webpacker", "~> 3.6"

gem "bootsnap", ">= 1.1.0", require: false
gem "octokit", "~> 4.0"

gem "git"
gem "omniauth"
gem "omniauth-github"
gem "sshkey"

gem "platform-api"

group :development, :test do
  gem "pry"
  gem "pry-rails"
  gem "standard"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rubocop", require: false
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
