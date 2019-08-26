class DropDeploymentConfigurationsAddons < ActiveRecord::Migration[5.2]
  def up
    drop_table :deployment_configurations_addons
  end

  def down
    create_table :deployment_configurations_addons do |t|
      t.belongs_to :deployment_configuration, foreign_key: true, index: false, null: false
      t.belongs_to :addon, foreign_key: true, index: true, null: false

      t.timestamps

      t.index :deployment_configuration_id, name: "index_deployment_configurations_addons_on_dep_configuration_id"
      t.index [:deployment_configuration_id, :addon_id], name: "index_deployment_configurations_addons_uniq_ids", unique: true
    end
  end
end
