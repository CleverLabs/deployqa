# frozen_string_literal: true

module Deployment
  module Helpers
    class PushCodeToServer
      def initialize(configuration)
        @configuration = configuration
      end

      def call
        git = GitWrapper.clone(@configuration.repo_path, @configuration.private_key)
        git.add_remote_heroku(@configuration.application_name)
        git.push_heroku(@configuration.git_reference)
        git.remove_dir
      end
    end
  end
end
