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
          { config: config.merge(url: url), env: { "DATABASE_URL" => url } }
        end,
        "ClearDB (MySQL)" => lambda do |_, _|
          config = {
            name: SecureRandom.alphanumeric,
            user: SecureRandom.alphanumeric,
            password: SecureRandom.alphanumeric,
            port: Robad::ResourceManagement::Port.allocate
          }
          url = "mysql2://#{config[:user]}:#{config[:password]}@#{ENV['DB_EXPOSURE_IP']}:#{config[:port]}/#{config[:name]}"
          { config: config.merge(url: url), env: { "DATABASE_URL" => url } }
        end,
        "Redis" => lambda do |_, _|
          config = {
            user: "redis",
            password: SecureRandom.alphanumeric,
            port: Robad::ResourceManagement::Port.allocate
          }
          url = "redis://#{config[:user]}:#{config[:password]}@#{ENV['DB_EXPOSURE_IP']}:#{config[:port]}"
          { config: config.merge(url: url), env: { "REDIS_URL" => url } }
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

      def initialize(repository, addon, application_name, docker_feature)
        @repository = repository
        @application_name = application_name
        @docker_feature = docker_feature
        @addon_record = addon
        @addon_data = @addon_record.attributes.slice(*Deployment::Addon.attributes.map(&:to_s))
        @addon_specific_data = ADDON_SPECIFIC_DATA[@addon_record.name]
      end

      def call
        return @addon_data unless @addon_specific_data
        return @addon_data if !@docker_feature.call && @addon_record.name != "AWS S3"

        specific_data = @addon_specific_data.call(@application_name, find_tokens)
        @addon_data["specific_configuration"] = specific_data.fetch(:config)
        @addon_data["credentials"] = specific_data.fetch(:env)
        @addon_data
      end

      private

      def find_tokens
        ProjectAddonInfo.find_by(project: @repository.project, addon: @addon_record)&.tokens
      end
    end
  end
end
