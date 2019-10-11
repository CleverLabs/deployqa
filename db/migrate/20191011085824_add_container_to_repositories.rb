class AddContainerToRepositories < ActiveRecord::Migration[5.2]
  def change
    add_column :repositories, :container, :integer, null: false, default: 0
  end
end
