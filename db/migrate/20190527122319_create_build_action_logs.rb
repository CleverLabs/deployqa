class CreateBuildActionLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :build_action_logs do |t|
      t.belongs_to :build_action, foreign_key: true, index: true, null: false
      t.text :message, null: false
      t.integer :status, null: false

      t.timestamps null: false
    end
  end
end
