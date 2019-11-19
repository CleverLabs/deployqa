class MoveUsersAuthUidAuthProviderToUserReferences  < ActiveRecord::Migration[5.2]
  User = Class.new(ActiveRecord::Base)

  class UserReference < ActiveRecord::Base
    enum auth_provider: ["github", "gitlab"]
  end

  def up
    User.find_each do |user|
      UserReference.create!(user_id: user.id, auth_provider: user.auth_provider, auth_uid: user.auth_uid, full_name: user.full_name)
    end
  end

  def down
    UserReference.destroy_all
  end
end
