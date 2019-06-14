class CreateGithubEntity < ActiveRecord::Migration[5.2]
  def change
    create_table :github_entities do |t|
      t.jsonb :data, default: {}, null: false
      t.string :owner_type, null: false
      t.bigint :owner_id, null: false

      t.timestamps null: false
    end

    add_index :github_entities, [:owner_type, :owner_id], unique: true
  end
end
