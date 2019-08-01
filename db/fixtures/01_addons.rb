# frozen_string_literal: true

Addon.seed(:name) do |seed|
  seed.name = "PostgreSQL"
  seed.integration_provider = AddonConstants::IntegrationProviders::HEROKU
end

Addon.seed(:name) do |seed|
  seed.name = "Redis"
  seed.integration_provider = AddonConstants::IntegrationProviders::HEROKU
end

Addon.seed(:name) do |seed|
  seed.name = "AWS S3"
  seed.integration_provider = AddonConstants::IntegrationProviders::AMAZON
end
