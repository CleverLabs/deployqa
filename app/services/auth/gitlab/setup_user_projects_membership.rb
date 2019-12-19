# frozen_string_literal: true

module Auth
  module Gitlab
    class SetupUserProjectsMembership
      def initialize(user)
        @user = user
      end

      def call; end
    end
  end
end
