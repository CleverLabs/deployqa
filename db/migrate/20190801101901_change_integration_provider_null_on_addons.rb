class ChangeIntegrationProviderNullOnAddons < ActiveRecord::Migration[5.2]
  def change
    change_column_null :addons, :integration_provider, false
  end
end
