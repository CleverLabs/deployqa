class AddGithubInstallationIdToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :github_installation_id, :integer
  end
end
