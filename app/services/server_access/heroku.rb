# frozen_string_literal: true

module ServerAccess
  class Heroku
    COMMAND_CHECK_DELAY = 10

    def initialize(name:)
      @heroku = PlatformAPI.connect_oauth(ENV["HEROKU_API_KEY"])
      @heroku_for_db = ::Heroku::Api::Postgres.connect_oauth(ENV["HEROKU_API_KEY"])
      @name = name
    end

    def create
      safely { @heroku.app.create(name: @name) }
    end

    def build_addons
      safely do
        @heroku.addon.create(@name, plan: "heroku-postgresql:hobby-dev")
        @heroku.addon.create(@name, plan: "heroku-redis:hobby-dev")
      end
    end

    def restart
      safely { @heroku.dyno.restart_all(@name) }
    end

    def destroy
      safely { @heroku.app.delete(@name) }
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

    def setup_worker
      safely { @heroku.formation.update(@name, "worker", quantity: 1) }
    end

    private

    def execute_command(command, env)
      dyno_id = @heroku.dyno.create(@name, command: command, env: env).fetch("id")

      sleep(COMMAND_CHECK_DELAY) while @heroku.dyno.list(@name).find { |dyno| dyno.fetch("id") == dyno_id }
    end

    def safely(&block)
      block.call
      ReturnValue.ok
    rescue Excon::Error::UnprocessableEntity => error
      ReturnValue.error(errors: error.response.data[:body])
    end
  end
end
