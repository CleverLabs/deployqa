class CreateInvoice < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.references :project, foreign_key: true, index: true, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false

      t.timestamps null: false
    end

    create_table :invoices_project_instances do |t|
      t.references :invoice, foreign_key: true, index: true, null: false
      t.references :project_instance, foreign_key: true, index: true, null: false
      t.bigint :build_action_ids, array: true, default: [], null: false

      t.timestamps null: false
    end
  end
end
