class CreateRepositorySettings < ActiveRecord::Migration[5.2]
  def change
    create_table :repository_settings do |t|
      t.belongs_to :repository, index: true, foreign_key: true, null: false
      t.jsonb :data, null: false

      t.timestamps null: false
    end
  end
end
