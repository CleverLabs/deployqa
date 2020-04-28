class AddPhpAddons < ActiveRecord::Migration[5.2]
  Addon = Class.new(ActiveRecord::Base)

  def up
    safety_assured do
      Addon.create!(name: "MariaDB", integration_provider: "robad", addon_type: "relational_db", credentials_names: ["DATABASE_URL"])
      Addon.create!(name: "phpMyAdmin", integration_provider: "robad", addon_type: "service")
      Addon.create!(name: "MailHog", integration_provider: "robad", addon_type: "service")
    end
  end
end
