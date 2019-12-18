class RemoveUsersWithEmptyTokens < ActiveRecord::Migration[5.2]
  User = Class.new(ActiveRecord::Base)

  def up
    User.where(token: nil).destroy_all
  end

  def down
    # Irreversible migration
  end
end
