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
        @configuration.project_integration_type == ProjectsConstants::Providers::VIA_SSH ? clone_repo_by_ssh : clone_repo_by_token
      end

      def clone_repo_by_token
        # TODO: extract GithubClient so we can use any integration client
        repo_uri = GithubAppClient.new(@configuration.project_integration_id).repo_uri(@configuration.repo_path)
        @git = GitWrapper.clone_by_uri(@configuration.repo_path, repo_uri)
        ReturnValue.ok
      rescue Git::GitExecuteError => error
        ReturnValue.error(errors: error.message)
      end

      def clone_repo_by_ssh
        @git = GitWrapper.clone_by_ssh(@configuration.repo_path, @configuration.project_integration_id)
        ReturnValue.ok
      end
    end
  end
end
