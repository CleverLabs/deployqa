class CreateBasicScheme < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :owner_id, null: false
      t.timestamps null: false
    end

    create_table :deployment_configurations do |t|
      t.bigint :project_id, null: false
      t.string :name, null: false
      t.timestamps null: false
    end

    create_table :project_instances do |t|
      t.bigint :project_id, null: false
      t.bigint :deployment_configuration_id, null: false
      t.string :deployment_status, null: false
      t.integer :git_reference, null: false
      t.timestamps null: false
    end

    create_table :build_actions do |t|
      t.bigint :author_id, null: false
      t.bigint :project_instance_id, null: false
      t.integer :action, null: false
      t.timestamps null: false
    end

    add_foreign_key :projects, :users, column: :owner_id
    add_foreign_key :deployment_configurations, :projects, column: :project_id
    add_foreign_key :project_instances, :projects, column: :project_id
    add_foreign_key :project_instances, :deployment_configurations, column: :deployment_configuration_id
    add_foreign_key :build_actions, :users, column: :author_id
    add_foreign_key :build_actions, :project_instances, column: :project_instance_id

    add_index :projects, :owner_id
    add_index :deployment_configurations, :project_id
    add_index :project_instances, :project_id
    add_index :build_actions, :author_id
    add_index :build_actions, :project_instance_id
  end
end
