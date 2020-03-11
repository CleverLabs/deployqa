# frozen_string_literal: true

module Plugins
  module Adapters
    class NewInstance
      include ShallowAttributes

      attribute :application_name, String
      attribute :addon_names, Array, of: String

      def self.by_configuration(configuration)
        new(
          application_name: configuration.fetch("application_name"),
          addon_names: configuration.fetch("addons").map { |addon| addon.fetch("name") }
        )
      end
    end
  end
end
