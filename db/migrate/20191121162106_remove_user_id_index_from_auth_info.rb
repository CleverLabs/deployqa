class RemoveUserIdIndexFromAuthInfo < ActiveRecord::Migration[5.2]
  def up
    remove_index :auth_infos, :user_id
    safety_assured { remove_column :auth_infos, :user_id }
  end

  def down
    add_column :auth_infos, :user_id, :bigint
    add_index :auth_infos, :user_id, unique: true
  end
end
