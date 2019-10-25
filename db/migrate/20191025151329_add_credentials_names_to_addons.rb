class AddCredentialsNamesToAddons < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :addons, :credentials_names, :string, array: true, default: [], null: false
    end
  end
end
