class AddSystemRoleToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :system_role, :integer
  end
end
