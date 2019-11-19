class ChangeAuthInfosTokenNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :auth_infos, :token, false
  end
end
