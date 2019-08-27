class DeleteVersionsForDeploymentConfigurations < ActiveRecord::Migration[5.2]
  Version = Class.new(ActiveRecord::Base)
  DELETING_TYPES = %w(DeploymentConfiguration DeploymentConfigurationsAddon)

  def up
    Version.where(item_type: DELETING_TYPES).find_each { |version_record| version_record.destroy! }
  end

  def down
    # Irreversible migration
  end
end
