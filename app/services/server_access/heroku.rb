# frozen_string_literal: true

module ServerAccess
  class Heroku
    COMMAND_CHECK_DELAY = 7
    MAX_NUMBER_OF_TRIES = 3
    TIME_TO_SLEEP_BEFORE_RETRY = 3
    SUCCESS_EXIT_CODE = 0

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
      safely_with_result { execute_command("RAILS_ENV=production bundle exec rails db:migrate", "DISABLE_DATABASE_ENVIRONMENT_CHECK" => 1) }
    end

    def setup_db
      safely_with_result { execute_command("bundle exec rails db:schema:load", "DISABLE_DATABASE_ENVIRONMENT_CHECK" => 1, "SAFETY_ASSURED" => 1) }
    end

    def run_command(command)
      safely_with_result { execute_command(command, "SAFETY_ASSURED" => 1) }
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

    def app_env_variables
      safely_with_result { @heroku.config_var.info_for_app(@name) }
    end

    private

    def execute_command(command, env)
      logs_url = @heroku.dyno.create(@name, command: "#{command}; echo $?", env: env, attach: true).fetch("attach_url")

      log_string, exit_code = dyno_log_and_exit_code(command, logs_url)

      raise ::Heroku::OneOffDynoError, log_string unless exit_code == SUCCESS_EXIT_CODE

      log_string
    end

    def dyno_log_and_exit_code(command, logs_url)
      rendezvous_client = Rendezvous.new(input: StringIO.new, output: StringIO.new, url: logs_url, activity_timeout: 15.minutes.to_i)
      rendezvous_client.start
      rendezvous_client.output.rewind
      logs = rendezvous_client.output.read.strip
      ["Log for '#{command}':\n#{logs.chop}", logs[-1].to_i]
    rescue StandardError
      ["Error capturing output for command '#{command}'", 1]
    end

    def safely(&block)
      result = safe_call(&block)
      return ReturnValue.ok if result.ok?
      result
    end

    def safely_with_result(&block)
      safe_call(&block)
    end

    def safe_call(&block)
      number_of_tries ||= 0
      result = block.call

      return ReturnValue.ok(Hash[(0...result.size).zip result]) if result.is_a?(Array)

      ReturnValue.ok(result) # Think how to handle non-objects
    rescue Excon::Error::UnprocessableEntity, Excon::Error::NotFound => error
      if (number_of_tries += 1) < MAX_NUMBER_OF_TRIES
        sleep TIME_TO_SLEEP_BEFORE_RETRY
        retry
      end

      ReturnValue.error(errors: error.response.data[:body])
    rescue ::Heroku::OneOffDynoError => error
      ReturnValue.error(errors: error.message)
    end
  end
end
