class AddTotalCostToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :total_cost_cents, :integer
  end
end
