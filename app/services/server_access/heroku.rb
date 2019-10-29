# frozen_string_literal: true

module ServerAccess
  class Heroku
    COMMAND_CHECK_DELAY = 7

    def initialize(name:)
      @heroku = PlatformAPI.connect_oauth(ENV["HEROKU_API_KEY"], cache: Moneta.new(:Null))
      @heroku_for_db = ::Heroku::Api::Postgres.connect_oauth(ENV["HEROKU_API_KEY"])
      @name = name
      @level = ServerAccess::HerokuHelpers::Level.new
    end

    def create(docker_build)
      safely do
        stack = docker_build ? "container" : nil
        if ENV["HEROKU_ORGANIZATION"].present?
          @heroku.organization_app.create(name: @name, organization: ENV["HEROKU_ORGANIZATION"], stack: stack)
        else
          @heroku.app.create(name: @name, stack: stack)
        end
      end
    end

    def push_buildpacks(buildpacks)
      updates = buildpacks.map { |buildpack| { buildpack: buildpack } }
      safely do
        @heroku.buildpack_installation.update(@name, updates: updates)
      end
    end

    def build_addons(addons)
      safely do
        addons.each do |addon|
          @heroku.addon.create(@name, plan: @level.addon(addon.name)) if addon.integration_provider == AddonConstants::IntegrationProviders::HEROKU
        end
      end
    end

    def restart
      safely { @heroku.dyno.restart_all(@name) }
    end

    def destroy
      safely do
        existing_apps = @heroku.app.list.map { |app| app["name"] }

        return ReturnValue.ok unless existing_apps.include?(@name)

        @heroku.app.delete(@name)
      end
    end

    def update_env_variables(env)
      safely { @heroku.config_var.update(@name, env) }
    end

    def migrate_db
      safely_with_log { execute_command("RAILS_ENV=production bundle exec rails db:migrate", "DISABLE_DATABASE_ENVIRONMENT_CHECK" => 1) }
    end

    def setup_db
      safely_with_log { execute_command("bundle exec rails db:schema:load", "DISABLE_DATABASE_ENVIRONMENT_CHECK" => 1, "SAFETY_ASSURED" => 1) }
    end

    def run_command(command)
      safely_with_log { execute_command(command, "SAFETY_ASSURED" => 1) }
    end

    def setup_processes(web_processes)
      safely do
        formations = web_processes.map do |web_process|
          {
            quantity: 1,
            size: @level.dyno_type,
            type: web_process.name
          }
        end
        @heroku.formation.batch_update(@name, updates: formations)
      end
    end

    private

    def execute_command(command, env)
      logs_url = @heroku.dyno.create(@name, command: command, env: env, attach: true).fetch("attach_url")

      begin
        rendezvous_client = Rendezvous.new(input: StringIO.new, output: StringIO.new, url: logs_url, activity_timeout: 15.minutes.to_i)
        rendezvous_client.start
        rendezvous_client.output.rewind
        "Log for '#{command}':\n#{rendezvous_client.output.read}"
      rescue StandardError
        "Error capturing output for command '#{command}'"
      end
    end

    def safely(&block)
      block.call
      ReturnValue.ok
    rescue Excon::Error::UnprocessableEntity, Excon::Error::NotFound => error
      ReturnValue.error(errors: error.response.data[:body])
    end

    def safely_with_log(&block)
      ReturnValue.ok(block.call)
    rescue Excon::Error::UnprocessableEntity, Excon::Error::NotFound => error
      ReturnValue.error(errors: error.response.data[:body])
    end
  end
end
