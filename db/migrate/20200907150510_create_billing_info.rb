class CreateBillingInfo < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      rename_table :application_costs, :application_plans
      add_column :application_plans, :max_allowed_instances, :integer, null: false, default: 3

      create_table :billing_infos do |t|
        t.references :project, null: false, foreign_key: true, unique: true
        t.references :application_plan, null: false, foreign_key: true

        t.decimal :sleep_cents, null: false
        t.decimal :run_cents, null: false
        t.decimal :build_cents, null: false
        t.boolean :active, null: false, default: true

        t.index :project_id, name: "unique_index_billing_infos_on_project_id", unique: true
      end
    end
  end
end
