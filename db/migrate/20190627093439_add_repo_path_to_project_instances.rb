class AddRepoPathToProjectInstances < ActiveRecord::Migration[5.2]
  def change
    add_column :project_instances, :attached_repo_path, :string
    rename_column :project_instances, :pull_request_number, :attached_pull_request_number
  end
end
