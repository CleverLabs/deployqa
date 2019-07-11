# frozen_string_literal: true

module Deployment
  module Helpers
    class PushCodeToServer
      def initialize(configuration, state)
        @configuration = configuration
        @repo_configuration = configuration.repo_configuration
        @state = state
        @git = nil
      end

      def call
        @state
          .add_state(:clone_repo) { clone_repo }
          .add_state(:generate_procfile) { @git.add_procfile(configuration.web_processes) }
          .add_state(:add_remote) { @git.add_remote_heroku(configuration.application_name) }
          .add_state(:push_code) { @git.push_heroku(@repo_configuration.git_reference) }
          .add_state(:clean_up_dir) { @git.remove_dir }
      end

      private

      attr_reader :configuration

      def clone_repo
        @repo_configuration.project_integration_type == ProjectsConstants::Providers::VIA_SSH ? clone_repo_by_ssh : clone_repo_by_token
      end

      def clone_repo_by_token
        # TODO: extract GithubClient so we can use any integration client
        repo_uri = GithubAppClient.new(@repo_configuration.project_integration_id).repo_uri(@repo_configuration.repo_path)
        @git = GitWrapper.clone_by_uri(@repo_configuration.repo_path, repo_uri)
        ReturnValue.ok
      rescue Git::GitExecuteError => error
        ReturnValue.error(errors: error.message)
      end

      def clone_repo_by_ssh
        @git = GitWrapper.clone_by_ssh(@repo_configuration.repo_path, @repo_configuration.project_integration_id)
        ReturnValue.ok
      end
    end
  end
end
