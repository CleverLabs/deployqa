class ChangeAuthInfosPrimaryNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :auth_infos, :primary, false
  end
end
