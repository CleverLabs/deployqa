# frozen_string_literal: true

module Deployment
  module ServerActions
    class Create
      def initialize(configurations, state_machine)
        @configurations = configurations
        @state_machine = state_machine
      end

      def call
        @configurations.each_with_object(@state_machine.start) do |configuration, state|
          @state_machine.context = configuration
          deploy_configuration(configuration, state)
        end
        @state_machine.finalize
      end

      private

      attr_reader :logger

      def deploy_configuration(configuration, state)
        state = create_server(configuration, state)
        state = push_code_to_server(configuration, state)
        create_infrastructure(configuration.application_name, configuration.web_processes, state)
      end

      def create_server(configuration, state)
        server = ServerAccess::Heroku.new(name: configuration.application_name)
        state = state
                .add_state(:create_server) { server.create(configuration.docker?) }
                .add_state(:update_env_variables) { server.update_env_variables(env_variables(configuration)) }

        Deployment::Helpers::AddonsBuilder.new(configuration, state, server).call
      end

      def create_infrastructure(app_name, web_processes, state)
        server = ServerAccess::Heroku.new(name: app_name)
        state
          .add_state(:setup_db) { server.setup_db }
          .add_state(:setup_processes) { server.setup_processes(web_processes) }
          .add_state(:restart_server) { server.restart }
      end

      def push_code_to_server(configuration, state)
        Deployment::Helpers::PushCodeToServer.new(configuration, state).call
      end

      def env_variables(configuration)
        repo_configuration = configuration.repo_configuration
        return configuration.env_variables unless repo_configuration.project_integration_type == ProjectsConstants::Providers::GITHUB

        configuration.env_variables.merge(
          "BUNDLE_GITHUB__COM" => ::ProviderAPI::Github::AppClient.new(repo_configuration.project_integration_id).token_for_gem_bundle
        )
      end
    end
  end
end
