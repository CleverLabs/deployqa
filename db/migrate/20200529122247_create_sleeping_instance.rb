class CreateSleepingInstance < ActiveRecord::Migration[5.2]
  def change
    create_table :sleeping_instances do |t|
      t.belongs_to :project_instance, index: true, foreign_key: true, null: false
      t.string :application_name, null: false, index: true
      t.string :urls, null: false, array: true

      t.timestamps null: false

      t.index [:project_instance_id, :application_name], name: "index_sleeping_instances_on_uniq_name", unique: true
    end
  end
end
