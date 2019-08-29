class CreateGitlabRepositoriesInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :gitlab_repositories_infos do |t|
      t.belongs_to :project, foreign_key: true, index: true, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
