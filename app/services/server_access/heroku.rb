# frozen_string_literal: true

module ServerAccess
  class Heroku
    def initialize(name:)
      @heroku = PlatformAPI.connect_oauth(ENV["HEROKU_API_KEY"], cache: Moneta.new(:Null))
      @heroku_for_db = ::Heroku::Api::Postgres.connect_oauth(ENV["HEROKU_API_KEY"])
      @name = name
      @level = ServerAccess::HerokuHelpers::Level.new
    end

    def create(docker_build)
      safe_call.safely do
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
      safe_call.safely do
        @heroku.buildpack_installation.update(@name, updates: updates)
      end
    end

    def build_addons(addons)
      safe_call.safely do
        addons.each do |addon|
          @heroku.addon.create(@name, plan: @level.addon(addon.name)) if addon.integration_provider == AddonConstants::IntegrationProviders::HEROKU
        end
      end
    end

    def restart
      safe_call.safely { @heroku.dyno.restart_all(@name) }
    end

    def destroy
      safe_call.safely do
        existing_apps = @heroku.app.list.map { |app| app["name"] }

        return ReturnValue.ok unless existing_apps.include?(@name)

        @heroku.app.delete(@name)
      end
    end

    def update_env_variables(env)
      safe_call.safely { @heroku.config_var.update(@name, env) }
    end

    def migrate_db
      safe_call.safely_with_result { shell_command.execute("RAILS_ENV=production bundle exec rails db:migrate", "DISABLE_DATABASE_ENVIRONMENT_CHECK" => 1) }
    end

    def setup_db
      safe_call.safely_with_result { shell_command.execute("bundle exec rails db:schema:load", "DISABLE_DATABASE_ENVIRONMENT_CHECK" => 1, "SAFETY_ASSURED" => 1) }
    end

    def run_command(command)
      safe_call.safely_with_result { shell_command.execute(command, "SAFETY_ASSURED" => 1) }
    end

    def setup_processes(web_processes)
      safe_call.safely do
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
      safe_call.safely_with_result { @heroku.config_var.info_for_app(@name) }
    end

    private

    def shell_command
      @_shell_command ||= ::ServerAccess::HerokuHelpers::ShellCommand.new(@heroku, @name)
    end

    def safe_call
      @_safe_call ||= ::ServerAccess::HerokuHelpers::SafeCall.new
    end
  end
end
