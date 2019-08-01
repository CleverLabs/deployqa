class AddIntegrationProviderToAddon < ActiveRecord::Migration[5.2]
  def change
    add_column :addons, :integration_provider, :integer
  end
end
