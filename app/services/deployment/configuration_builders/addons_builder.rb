# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class AddonsBuilder
      ADDON_SPECIFIC_DATA = {
        "PostgreSQL" => lambda do |_, _|
          config = {
            name: SecureRandom.alphanumeric,
            user: SecureRandom.alphanumeric,
            password: SecureRandom.alphanumeric,
            port: Robad::ResourceManagement::Port.allocate
          }
          url = "postgres://#{config[:user]}:#{config[:password]}@#{ENV['DB_EXPOSURE_IP']}:#{config[:port]}/#{config[:name]}"
          { config: config.merge(url: url), env: { DATABASE_URL: url } }
        end,
        "ClearDB (MySQL)" => lambda do |_, _|
          config = {
            name: SecureRandom.alphanumeric,
            user: SecureRandom.alphanumeric,
            password: SecureRandom.alphanumeric,
            port: Robad::ResourceManagement::Port.allocate
          }
          url = "mysql2://#{config[:user]}:#{config[:password]}@#{ENV['DB_EXPOSURE_IP']}:#{config[:port]}/#{config[:name]}"
          { config: config.merge(url: url), env: { DATABASE_URL: url } }
        end,
        "Redis" => lambda do |_, _|
          config = {
            user: "redis",
            password: SecureRandom.alphanumeric,
            port: Robad::ResourceManagement::Port.allocate
          }
          url = "redis://#{config[:user]}:#{config[:password]}@#{ENV['DB_EXPOSURE_IP']}:#{config[:port]}"
          { config: config.merge(url: url), env: { REDIS_URL: url } }
        end,
        "AWS S3" => lambda do |application_name, tokens|
          env = {
            "S3_BUCKET" => Deployment::ConfigurationBuilders::NameBuilder.new.external_resource_name(application_name),
            "S3_KEY_ID" => tokens.fetch("access_key_id"),
            "S3_ACCESS_KEY" => tokens.fetch("secret_access_key"),
            "S3_REGION" => ENV["AWS_REGION"]
          }
          { config: {}, env: env }
        end
      }.freeze

      def initialize(repository, addon, application_name)
        @repository = repository
        @project = repository.project
        @addon = addon
        @application_name
      end

      def call
        data = @addon.attributes.slice(*Deployment::Addon.attributes.map(&:to_s))
        return data unless ADDON_SPECIFIC_DATA[@addon.name]

        tokens = ProjectAddonInfo.find_by(project: @project, addon: @addon)&.tokens
        specific_data = ADDON_SPECIFIC_DATA.fetch(@addon.name).call(@application_name, tokens)
        data["specific_configuration"] = specific_data.fetch(:config)
        data["credentials"] = specific_data.fetch(:env)
        data
      end
    end
  end
end
