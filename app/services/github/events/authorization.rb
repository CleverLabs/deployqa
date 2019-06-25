# frozen_string_literal: true

module Github
  module Events
    class Authorization
      include ShallowAttributes

      attribute :payload, Hash

      def id
        payload.dig("sender", "id")
      end
    end
  end
end
