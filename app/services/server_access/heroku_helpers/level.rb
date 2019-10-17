# frozen_string_literal: true

module ServerAccess
  module HerokuHelpers
    class Level
      ADDONS_MAPPING = {
        "PostgreSQL" => ->(development) { development ? "heroku-postgresql:hobby-dev" : "heroku-postgresql:hobby-basic" },
        "ClearDB (MySQL)" => ->(development) { development ? "cleardb:ignite" : "cleardb:punch" },
        "Redis" => ->(_) { "heroku-redis:hobby-dev" }
      }.freeze

      def initialize
        @development = !Rails.env.production?
      end

      def addon(addon_name)
        ADDONS_MAPPING.fetch(addon_name).call(@development)
      end

      def dyno_type
        @development ? "Free" : "standard-1X"
      end
    end
  end
end
