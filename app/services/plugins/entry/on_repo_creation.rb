# frozen_string_literal: true

module Plugins
  module Entry
    class OnRepoCreation
      def initialize(project_info)
        @project_info = project_info
      end

      def call; end
    end
  end
end
