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
        git = clone_repo
        @logger.info("Add heroku remote") && git.add_remote_heroku(application_name)
        @logger.info("Push code to the heroku remote") && git.push_heroku(@configuration.git_reference)
        @logger.info("Remove temporary directory") && git.remove_dir
      end

      private

      attr_reader :application_name

      def clone_repo
        # TODO: extract GithubClient so we can use any integration client
        repo_uri = GithubClient.new(@configuration.installation_id).repo_uri(@configuration.repo_path)
        GitWrapper.clone(@configuration.repo_path, repo_uri)
      end
    end
  end
end
