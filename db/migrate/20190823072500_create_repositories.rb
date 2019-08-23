class CreateRepositories < ActiveRecord::Migration[5.2]
  def change
    create_table :repositories do |t|
      t.belongs_to :project, foreign_key: true, index: true, null: false
      t.string :name, null: false
      t.integer :integration_type, null: false
      t.string :integration_id, null: false
      t.integer :status, null: false
      t.string :path, null: false
      t.jsonb :env_variables, null: false, default: {}

      t.timestamps

      t.index [:integration_id, :integration_type], unique: true
      t.index [:project_id, :path], unique: true
    end

  end
end
