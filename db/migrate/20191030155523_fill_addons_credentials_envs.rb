class FillAddonsCredentialsEnvs < ActiveRecord::Migration[5.2]
  Addon = Class.new(ActiveRecord::Base)

  ADDON_CREDENTIALS_NAMES = {
    "PostgreSQL" => %W(DATABASE_URL),
    "ClearDB (MySQL)" => %W(DATABASE_URL),
    "Redis" => %W(REDIS_URL),
  }.freeze

  def up
    Addon.find_each do |addon|
      next unless ADDON_CREDENTIALS_NAMES.key?(addon.name)

      addon.update(credentials_names: ADDON_CREDENTIALS_NAMES.fetch(addon.name))
    end
  end

  def down
    Addon.find_each do |addon|
      addon.update(credentials_names: [])
    end
  end
end
