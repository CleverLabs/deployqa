class AddPullRequestNumberToProjectInstances < ActiveRecord::Migration[5.2]
  def change
    add_column :project_instances, :pull_request_number, :integer
  end
end
