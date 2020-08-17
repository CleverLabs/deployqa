class AddLifecyclesToInvoicesProjectInstances < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :invoices_project_instances, :lifecycle, :jsonb, default: {}, null: false
      remove_column :invoices_project_instances, :build_action_ids, :bigint, array: true
    end
  end
end
