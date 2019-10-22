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
        state = @state
                .add_state(:clone_repo) { clone_repo }
                .add_state(:select_branch) { @git.select_branch(@repo_configuration.git_reference) }

        push_to_heroku(state)
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

      def push_to_heroku(state)
        state
          .add_state(:generate_config_file) { generate_config_file }
          .add_state(:add_remote) { @git.add_remote_heroku(configuration.application_name) }
          .add_state(:push_code) { @git.push_heroku(@repo_configuration.git_reference) }
      end

      def generate_config_file
        return ReturnValue.ok if configuration.web_processes.blank?

        @git.add_file(config_file_options(configuration))
      end

      def config_file_options(configuration)
        if configuration.docker?
          private_gem_detected = @configuration.build_configuration.private_gem_detected
          content = ServerAccess::HerokuHelpers::DockerDeployConfigGenerator.new(configuration.web_processes, @repo_configuration.project_integration_id, private_gem_detected).call
          { content: content, filename: "heroku.yml" }
        else
          { content: ServerAccess::HerokuHelpers::ProcfileGenerator.new(configuration.web_processes).call, filename: "Procfile" }
        end
      end
    end
  end
end
