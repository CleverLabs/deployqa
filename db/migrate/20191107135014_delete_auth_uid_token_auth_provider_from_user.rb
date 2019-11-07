class DeleteAuthUidTokenAuthProviderFromUser < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :users, :auth_uid, :string
      remove_column :users, :auth_provider, :string
      remove_column :users, :token, :string
    end
  end
end
