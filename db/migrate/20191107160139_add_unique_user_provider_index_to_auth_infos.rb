class AddUniqueUserProviderIndexToAuthInfos < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :auth_infos, [:user_id, :provider], unique: true, algorithm: :concurrently
  end
end
