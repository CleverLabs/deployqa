class AddBuildpacksToRepositories < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :repositories, :heroku_buildpacks, :string, array: true, default: [], null: false
    end
  end
end
