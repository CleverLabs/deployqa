class AddMigrationCommandAndSchemaLoadCommandToRepositories < ActiveRecord::Migration[5.2]
  def change
    add_column :repositories, :migration_command, :string
    add_column :repositories, :schema_load_command, :string
  end
end
