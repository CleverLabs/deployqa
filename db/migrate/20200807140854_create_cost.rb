class CreateCost < ActiveRecord::Migration[5.2]
  def change
    create_table :application_costs do |t|
      t.string :name, null: false, index: true
      t.integer :sleep_cents, null: false
      t.integer :run_cents, null: false
      t.integer :build_cents, null: false

      t.timestamps null: false
    end
  end
end
