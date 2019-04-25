# frozen_string_literal: true

module ServerAccess
  class Heroku
    def initialize
      @heroku = PlatformAPI.connect_oauth(ENV["HEROKU_TOKEN"])
    end

    def create(name:)
      @heroku.app.create(name: name)
    end

    def update; end

    def restart(name:)
      heroku.dyno.restart_all(name)
    end

    def destroy(name:)
      heroku.app.delete(name)
    end
  end
end
