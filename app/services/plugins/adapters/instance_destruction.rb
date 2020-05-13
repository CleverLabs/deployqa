# frozen_string_literal: true

module Plugins
  module Adapters
    class InstanceDestruction
      include ShallowAttributes

      attribute :application_name, String
      attribute :addon_names, Array, of: String
      attribute :addon_ports, Array, of: Integer

      def self.by_configuration(configuration)
        new(
          application_name: configuration.application_name,
          addon_names: configuration.addons.map(&:name),
          addon_ports: configuration.addons.map { |addon| addon.specific_configuration["port"] }
        )
      end
    end
  end
end
