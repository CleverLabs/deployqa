class RenameMigrationsToSeeds < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_column :repositories, :migration_command, :seeds_command
    end
  end
end
