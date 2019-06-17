class DeleteReposAndSecrets < ActiveRecord::Migration[5.2]
  def change
    drop_table :repos
    drop_table :secrets
  end
end
