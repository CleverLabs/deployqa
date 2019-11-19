class ChangeAuthInfosEmailNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :auth_infos, :email, false
  end
end
