class RemoveGitReferenceFromProjectInstance < ActiveRecord::Migration[5.2]
  def change
    remove_column :project_instances, :git_reference, :integer
  end
end
