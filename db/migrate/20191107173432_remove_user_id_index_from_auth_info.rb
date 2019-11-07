class RemoveUserIdIndexFromAuthInfo < ActiveRecord::Migration[5.2]
  def up
    remove_index :auth_infos, :user_id
  end

  def down
    add_index :auth_infos, :user_id, unique: true, algorithm: :concurrently
  end
end
