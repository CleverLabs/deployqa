class RenameContainerToBuildTypeOnRepositories < ActiveRecord::Migration[5.2]
  def change
    safety_assured { rename_column :repositories, :container, :build_type }
  end
end
