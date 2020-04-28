# frozen_string_literal: true

Addon.seed(:name) do |seed|
  seed.name = "PostgreSQL"
  seed.integration_provider = AddonConstants::IntegrationProviders::HEROKU
  seed.credentials_names = %W(DATABASE_URL)
end

Addon.seed(:name) do |seed|
  seed.name = "ClearDB (MySQL)"
  seed.integration_provider = AddonConstants::IntegrationProviders::HEROKU
  seed.credentials_names = %W(DATABASE_URL)
end

Addon.seed(:name) do |seed|
  seed.name = "Redis"
  seed.integration_provider = AddonConstants::IntegrationProviders::HEROKU
  seed.credentials_names = %W(REDIS_URL)
end

Addon.seed(:name) do |seed|
  seed.name = "AWS S3"
  seed.integration_provider = AddonConstants::IntegrationProviders::AMAZON
end

Addon.seed(:name) do |seed|
  seed.name = "MariaDB"
  seed.integration_provider = AddonConstants::IntegrationProviders::ROBAD
end

Addon.seed(:name) do |seed|
  seed.name = "MailHog"
  seed.integration_provider = AddonConstants::IntegrationProviders::ROBAD
end

Addon.seed(:name) do |seed|
  seed.name = "phpMyAdmin"
  seed.integration_provider = AddonConstants::IntegrationProviders::ROBAD
end
