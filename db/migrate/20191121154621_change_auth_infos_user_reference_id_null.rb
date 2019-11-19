class ChangeAuthInfosUserReferenceIdNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :auth_infos, :user_reference_id, false
  end
end
