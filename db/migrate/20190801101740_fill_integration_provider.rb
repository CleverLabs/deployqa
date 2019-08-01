class FillIntegrationProvider < ActiveRecord::Migration[5.2]
  Addon = Class.new(ActiveRecord::Base)

  def up
    Addon.find_each do |addon|
      addon.update_columns(integration_provider: 0)
    end
  end
end
