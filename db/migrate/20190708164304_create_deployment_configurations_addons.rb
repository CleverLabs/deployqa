class CreateDeploymentConfigurationsAddons < ActiveRecord::Migration[5.2]
  def change
    create_table :deployment_configurations_addons do |t|
      t.bigint :deployment_configuration_id, null: false
      t.bigint :addon_id, null: false
    end

    add_index :deployment_configurations_addons, [:addon_id, :deployment_configuration_id], unique: true, name: "deployment_configurations_addons_uniq_index"
  end
end
