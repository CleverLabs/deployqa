class CreateNomadReferences < ActiveRecord::Migration[5.2]
  def change
    create_table :nomad_references do |t|
      t.references :project_instance, foreign_key: true, index: true, null: false
      t.string :allocation_id, null: false
      t.string :process_name, null: false
      t.string :application_name, null: false
    end
  end
end
