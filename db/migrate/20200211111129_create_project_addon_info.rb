class CreateProjectAddonInfo < ActiveRecord::Migration[5.2]
  def change
    create_table :project_addon_infos do |t|
      t.jsonb :tokens, null: false, default: {}
      t.references :project, foreign_key: true, index: true, null: false
      t.references :addon, foreign_key: true, index: true, null: false

      t.timestamps null: false
    end

    add_index :project_addon_infos, [:project_id, :addon_id], unique: true
  end
end
