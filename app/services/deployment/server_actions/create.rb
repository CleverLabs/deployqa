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

        @state_machine.finalize(configurations_with_credentials)
      end

      private

      def deploy_configuration(configuration, state)
        state = create_server(configuration, state)
        state = push_buildpacks(configuration, state)
        state = push_code_to_server(configuration, state)
        create_infrastructure(configuration.application_name, configuration.web_processes, configuration, state)
      end

      def create_server(configuration, state)
        server = ServerAccess::Heroku.new(name: configuration.application_name)

        state = state.add_state(:create_server) { server.create(configuration.docker?) }
        state = Deployment::Helpers::AddonsBuilder.new(configuration, state, server).call
        state.add_state(:update_env_variables) { update_env_variables(configuration, server) }
      end

      def create_infrastructure(app_name, web_processes, configuration, state)
        server = ServerAccess::Heroku.new(name: app_name)

        state.add_state(:setup_db) { server.setup_db } if configuration.db_addon_present?
        state.add_state(:load_seeds) { server.run_command(configuration.seeds_command) } if configuration.fill_seeds?

        state.add_state(:setup_processes) { server.setup_processes(web_processes) }
      end

      def push_buildpacks(configuration, state)
        return state if configuration.heroku_buildpacks.blank?

        server = ServerAccess::Heroku.new(name: configuration.application_name)
        state.add_state(:push_buildpacks) { server.push_buildpacks(configuration.heroku_buildpacks) }
      end

      def push_code_to_server(configuration, state)
        Deployment::Helpers::PushCodeToServer.new(configuration, state).call
      end

      def update_env_variables(configuration, server)
        env_variables_result = server.app_env_variables
        return env_variables_result unless env_variables_result.ok?

        configuration.env_variables.merge!(env_variables_result.object)

        # TODO: temp solution. Probably should be another addon
        if configuration.env_variables["CLEARDB_DATABASE_URL"]
          configuration.env_variables["CLEARDB_DATABASE_URL"] = configuration.env_variables["CLEARDB_DATABASE_URL"].gsub("mysql", "mysql2").gsub("?reconnect=true", "")
        end

        server.update_env_variables(env_variables(configuration))
      end

      def env_variables(configuration)
        Deployment::Helpers::EnvAliasing.new(configuration.env_variables).modify!
        repo_configuration = configuration.repo_configuration
        return configuration.env_variables if !configuration.build_configuration.private_gem_detected || configuration.docker?

        configuration.env_variables.merge(
          "BUNDLE_GITHUB__COM" => ::ProviderApi::Github::AppClient.new(repo_configuration.project_integration_id).token_for_gem_bundle
        )
      end

      def configurations_with_credentials
        configurations_with_credentials = nil

        @state_machine.add_state(:fetch_addons_credentials) do
          configurations_with_credentials = add_credentials_to_configurations
          ReturnValue.ok
        end

        configurations_with_credentials
      end

      def add_credentials_to_configurations
        @configurations.map do |configuration|
          server = ServerAccess::Heroku.new(name: configuration.application_name)
          addons_with_credentials = ::Deployment::Helpers::AddonsCredentialsParser.new(server, configuration.addons).call
          configuration.addons = addons_with_credentials.map(&:attributes)
          configuration.to_project_instance_configuration
        end
      end
    end
  end
end
