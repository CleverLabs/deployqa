class AddBranchesToProjectInstance < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :project_instances, :branches, :jsonb, default: {}, null: false
    end
  end
end
