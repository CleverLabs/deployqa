# frozen_string_literal: true

module Plugins
  module Adapters
    class InstanceDestruction
      include ShallowAttributes

      attribute :application_name, String
      attribute :addon_names, Array, of: String

      def self.by_configuration(configuration)
        new(
          application_name: configuration.application_name,
          addon_names: configuration.addons.map(&:name)
        )
      end
    end
  end
end
