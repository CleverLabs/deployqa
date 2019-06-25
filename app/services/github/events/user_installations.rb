# frozen_string_literal: true

module Github
  module Events
    class UserInstallations
      include ShallowAttributes

      Installation = Struct.new(:id)

      attribute :payload, Hash

      def installations
        payload[:installations].map do |installation_info|
          Installation.new(installation_info[:id])
        end
      end
    end
  end
end
