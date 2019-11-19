class AddTokenAndUserReferenceIdToAuthInfo < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_infos, :token, :string
    add_column :auth_infos, :primary, :boolean, default: false
    add_column :auth_infos, :email, :string
    add_reference :auth_infos, :user_reference, foreign_key: true, null: true, index: false
  end
end
