# frozen_string_literal: true

module ServerAccess
  class HerokuDatabase
    def initialize(name:)
      @heroku = PlatformAPI.connect_oauth(ENV["HEROKU_API_KEY"])
      @heroku_for_db = Heroku::Api::Postgres.connect_oauth(ENV["HEROKU_API_KEY"])
      @database_id = find_database_id
      @name = name
    end

    def start_db_dump
      @heroku_for_db.backups.capture(@name, @database_id)
    end

    def dumps_list
      @heroku_for_db.backups.list(@name)
    end

    def link_to_dump(dump_uid)
      @heroku_for_db.backups.url(@name, dump_uid).fetch(:url)
    end

    def upload(dump_url)
      @heroku_for_db.backups.restore(@name, @database_id, dump_url)
    end

    private

    def find_database_id
      @heroku.addon.list.find { |addon| addon["addon_service"]["name"] == "heroku-postgresql" }.fetch("id")
    end
  end
end
