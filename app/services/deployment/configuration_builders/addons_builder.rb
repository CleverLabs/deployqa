# frozen_string_literal: true

module Deployment
  module ConfigurationBuilders
    class AddonsBuilder
      ADDON_SPECIFIC_DATA = {
        "PostgreSQL" => lambda do
          config = {
            name: SecureRandom.alphanumeric,
            user: SecureRandom.alphanumeric,
            password: SecureRandom.alphanumeric,
            port: rand(10000..20000)
          }
          url = "postgres://#{config[:user]}:#{config[:password]}@#{ENV['DB_EXPOSURE_IP']}:#{config[:port]}/#{config[:name]}"
          { config: config.merge(url: url), env: { DATABASE_URL: url } }
        end
      }.freeze

      def initialize(repository, addon)
        @repository = repository
        @addon = addon
      end

      def call
        data = @addon.attributes.slice(*Deployment::Addon.attributes.map(&:to_s))
        return data unless ADDON_SPECIFIC_DATA[@addon.name]

        specific_data = ADDON_SPECIFIC_DATA.fetch(@addon.name).call
        data["specific_configuration"] = specific_data.fetch(:config)
        data["credentials"] = specific_data.fetch(:env)
        data
      end
    end
  end
end