class ChangeSystemRoleNullOnUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :system_role, false
    change_column_default :users, :system_role, 0
  end
end
