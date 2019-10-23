class AddBuildEnvVariablesToRepositories < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_column :repositories, :env_variables, :runtime_env_variables
      add_column :repositories, :build_env_variables, :jsonb, default: {}, null: false
    end
  end
end
