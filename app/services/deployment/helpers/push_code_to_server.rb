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
        @git = Deployment::Helpers::RepositoryCloner.new(@repo_configuration).call
        ReturnValue.ok
      rescue Git::GitExecuteError => error
        ReturnValue.error(errors: error.message)
      end
    end
  end
end
