class AddMigrationCommandToRepositories < ActiveRecord::Migration[5.2]
  def change
    add_column :repositories, :migration_command, :string
  end
end
