class AddBranchesToProjectInstance < ActiveRecord::Migration[5.2]
  def change
    add_column :project_instances, :branches, :jsonb, default: {}, null: false
  end
end
