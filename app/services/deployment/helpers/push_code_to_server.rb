# frozen_string_literal: true

module Deployment
  module Helpers
    class PushCodeToServer
      def initialize(configuration, logger)
        @configuration = configuration
        @logger = logger
        @application_name = configuration.application_name
      end

      def call
        @logger.info("Clone repository")
        git = GitWrapper.clone(@configuration.repo_path, @configuration.private_key)
        @logger.info("Add heroku remote") && git.add_remote_heroku(application_name)
        @logger.info("Push code to the heroku remote") && git.push_heroku(@configuration.git_reference)
        @logger.info("Remove temporary directory") && git.remove_dir
      end

      private

      attr_reader :application_name
    end
  end
end
