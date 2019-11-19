class RemoveUsersForeignKeyFromAuthInfos < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :auth_infos, column: :user_id
    change_column_null :auth_infos, :user_id, true
  end
end
