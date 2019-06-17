class CreateSlackEntity < ActiveRecord::Migration[5.2]
  def change
    create_table :slack_entities do |t|
      t.belongs_to :project, index: false, foreign_key: true, null: false
      t.jsonb :data, null: false

      t.timestamps null: false
      t.index :project_id, unique: true
    end
  end
end
