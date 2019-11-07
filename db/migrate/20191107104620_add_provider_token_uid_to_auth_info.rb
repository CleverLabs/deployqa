class AddProviderTokenUidToAuthInfo < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_infos, :provider, :integer
    add_column :auth_infos, :token, :string
    add_column :auth_infos, :uid, :string
  end
end
