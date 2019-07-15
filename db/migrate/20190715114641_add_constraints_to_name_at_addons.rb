class AddConstraintsToNameAtAddons < ActiveRecord::Migration[5.2]
  def up
    add_index :addons, :name, unique: true
  end
end
