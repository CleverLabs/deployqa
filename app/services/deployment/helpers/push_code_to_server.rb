# frozen_string_literal: true

module Deployment
  module Helpers
    class PushCodeToServer
      def initialize(configuration, state)
        @configuration = configuration
        @state = state
        @application_name = configuration.application_name
        @git = nil
      end

      def call
        @state
          .add_state(:clone_repo) { clone_repo }
          .add_state(:add_remote) { @git.add_remote_heroku(application_name) }
          .add_state(:push_code) { @git.push_heroku(@configuration.git_reference) }
          .add_state(:clean_up_dir) { @git.remove_dir }
      end

      private

      attr_reader :application_name

      def clone_repo
        # TODO: extract GithubClient so we can use any integration client
        repo_uri = GithubClient.new(@configuration.installation_id).repo_uri(@configuration.repo_path)
        @git = GitWrapper.clone(@configuration.repo_path, repo_uri)
        ReturnValue.ok
      rescue Git::GitExecuteError => error
        ReturnValue.error(errors: error.message)
      end
    end
  end
end
