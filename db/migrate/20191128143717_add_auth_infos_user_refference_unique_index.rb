class AddAuthInfosUserRefferenceUniqueIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :auth_infos, :user_reference_id, unique: true, algorithm: :concurrently
  end
end
