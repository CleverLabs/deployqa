class RemoveGithubSecretTokenFromProjects < ActiveRecord::Migration[5.2]
  def change
    remove_column :projects, :github_secret_token, :string
  end
end
