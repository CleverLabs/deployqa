class ChangeRepositoriesUniqueIndex < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      remove_index :repositories, column: [:integration_id, :integration_type], name: "index_repositories_on_integration_id_and_integration_type"
      add_index :repositories, [:project_id, :integration_id, :integration_type],
                name: "index_repositories_on_project_id_integration_id_and_type",
                unique: true
    end
  end

  def down
    safety_assured do
      remove_index :repositories, column: [:project_id, :integration_id, :integration_type], name: "index_repositories_on_project_id_integration_id_and_type"
      add_index :repositories, [:integration_id, :integration_type],
                name: "index_repositories_on_integration_id_and_integration_type",
                unique: true
    end
  end
end
