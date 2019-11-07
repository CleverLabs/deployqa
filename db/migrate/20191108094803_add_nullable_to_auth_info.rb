class AddNullableToAuthInfo < ActiveRecord::Migration[5.2]
  def change
    change_column_null :auth_infos, :provider, false
    change_column_null :auth_infos, :token, false
    change_column_null :auth_infos, :uid, false
  end
end
