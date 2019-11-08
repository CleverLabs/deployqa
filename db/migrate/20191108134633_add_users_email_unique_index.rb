class AddUsersEmailUniqueIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :users, :email, unique: true, algorithm: :concurrently
  end
end
