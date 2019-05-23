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
      @heroku.app.create(name: @name)
    end

    def build_addons
      @heroku.addon.create(@name, plan: "heroku-postgresql:hobby-dev")
    end

    def restart
      @heroku.dyno.restart_all(@name)
    end

    def destroy
      @heroku.app.delete(@name)
    end

    def update_env_variables(env)
      @heroku.config_var.update(@name, env)
    end

    def migrate_db
      execute_command("RAILS_ENV=production rails db:migrate", {})
    end

    private

    def execute_command(command, env)
      dyno_id = @heroku.dyno.create(@name, command: command, env: env).fetch("id")

      sleep(COMMAND_CHECK_DELAY) while @heroku.dyno.list(@name).find { |dyno| dyno.fetch("id") == dyno_id }
    end
  end
end
