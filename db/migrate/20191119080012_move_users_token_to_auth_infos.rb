class MoveUsersTokenToAuthInfos < ActiveRecord::Migration[5.2]
  class User < ActiveRecord::Base
    has_one :auth_info
  end

  class AuthInfo < ActiveRecord::Base
    belongs_to :user
  end

  def up
    User.find_each do |user|
      user.auth_info.update!(token: user.token)
    end
  end

  def down
    AuthInfo.find_each do |auth_info|
      auth_info.update!(token: nil)
    end
  end
end
