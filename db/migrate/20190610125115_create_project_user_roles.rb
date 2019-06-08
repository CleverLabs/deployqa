class CreateProjectUserRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :project_user_roles do |t|
      t.references :project, foreign_key: true, index: true, null: false
      t.references :user, foreign_key: true, index: true, null: false
      t.string :role, null: false

      t.timestamps null: false
      t.index [:project_id, :user_id], unique: true
    end
  end
end
