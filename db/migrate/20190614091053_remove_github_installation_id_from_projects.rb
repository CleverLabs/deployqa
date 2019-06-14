class RemoveGithubInstallationIdFromProjects < ActiveRecord::Migration[5.2]
  def change
    remove_column :projects, :github_installation_id, :integer
  end
end
