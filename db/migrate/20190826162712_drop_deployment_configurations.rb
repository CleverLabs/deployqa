class DropDeploymentConfigurations < ActiveRecord::Migration[5.2]
  def up
    drop_table :deployment_configurations
  end

  def down
    create_table :deployment_configurations do |t|
      t.belongs_to :project, foreign_key: true, index: true, null: false
      t.string :name, null: false
      t.integer :integration_type, null: false
      t.string :integration_id, null: false
      t.integer :status, null: false
      t.string :repo_path, null: false
      t.jsonb :env_variables, null: false, default: {}

      t.timestamps

      t.index [:integration_id, :integration_type], name: "index_deployment_configurations_on_integration_id_and_type", unique: true
      t.index [:project_id, :repo_path], unique: true
    end
  end
end
