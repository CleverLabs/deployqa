# frozen_string_literal: true

module ServerAccess
  class Heroku
    COMMAND_CHECK_DELAY = 12

    def initialize(name:)
      @heroku = PlatformAPI.connect_oauth(ENV["HEROKU_API_KEY"])
      @heroku_for_db = ::Heroku::Api::Postgres.connect_oauth(ENV["HEROKU_API_KEY"])
      @name = name
      @level = ServerAccess::HerokuHelpers::Level.new
    end

    def create
      safely do
        if ENV["HEROKU_ORGANIZATION"].present?
          @heroku.organization_app.create(name: @name, organization: ENV["HEROKU_ORGANIZATION"])
        else
          @heroku.app.create(name: @name)
        end
      end
    end

    def build_addons(addons_names)
      safely do
        addons_names.each do |addon_name|
          @heroku.addon.create(@name, plan: @level.addon(addon_name))
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
      safely { execute_command("RAILS_ENV=production rails db:migrate", {}) }
    end

    def setup_db
      safely { execute_command("rails db:schema:load", "DISABLE_DATABASE_ENVIRONMENT_CHECK" => 1) }
    end

    def setup_worker(web_processes)
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
      dyno_id = @heroku.dyno.create(@name, command: command, env: env).fetch("id")

      sleep(COMMAND_CHECK_DELAY) while @heroku.dyno.list(@name).find do |dyno|
        puts " -- Waiting, id is: #{dyno.fetch('id')}, desirable is: #{dyno_id}"
        dyno.fetch("id") == dyno_id
      end
    end

    def safely(&block)
      block.call
      ReturnValue.ok
    rescue Excon::Error::UnprocessableEntity, Excon::Error::NotFound => error
      ReturnValue.error(errors: error.response.data[:body])
    end
  end
end
