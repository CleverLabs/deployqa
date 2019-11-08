# frozen_string_literal: true

module Omniauth
  module Gitlab
    class AddUserToProjects
      def initialize(user)
        @user = user
      end

      def call; end
    end
  end
end
