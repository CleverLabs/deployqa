class AddAddonTypeToAddons < ActiveRecord::Migration[5.2]
  class Addon < ActiveRecord::Base
    enum addon_type: %w(relational_db key_value_db cloud_storage)
  end

  def up
    safety_assured do
      add_column :addons, :addon_type, :integer

      Addon.find_by(name: "PostgreSQL").update(addon_type: "relational_db")
      Addon.find_by(name: "ClearDB (MySQL)").update(addon_type: "relational_db")
      Addon.find_by(name: "Redis").update(addon_type: "key_value_db")
      Addon.find_by(name: "AWS S3").update(addon_type: "cloud_storage")

      change_column_null :addons, :addon_type, false
    end
  end

  def down
    remove_column :addons, :addon_type
  end
end
