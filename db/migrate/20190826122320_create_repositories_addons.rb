class CreateRepositoriesAddons < ActiveRecord::Migration[5.2]
  def change
    create_table :repositories_addons do |t|
      t.belongs_to :repository, foreign_key: true, index: true, null: false
      t.belongs_to :addon, foreign_key: true, index: true, null: false

      t.timestamps

      t.index [:repository_id, :addon_id], unique: true
    end
  end
end
