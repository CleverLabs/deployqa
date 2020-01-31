# frozen_string_literal: true

module AddonConstants
  module IntegrationProviders
    ALL = [
      HEROKU = "heroku",
      AMAZON = "amazon"
    ].freeze
  end

  module Types
    ALL = [
      RELATIONAL_DB = "relational_db",
      KEY_VALUE_DB = "key_value_db",
      CLOUD_STORAGE = "cloud_storage"
    ].freeze
  end
end
