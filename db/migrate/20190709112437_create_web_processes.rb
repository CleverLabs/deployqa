class CreateWebProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :web_processes do |t|
      t.belongs_to :deployment_configuration, foreign_key: true, index: true, null: false
      t.string :name, null: false
      t.string :command, null: false
      t.integer :number, null: false, default: 1

      t.timestamps null: false
    end
  end
end
