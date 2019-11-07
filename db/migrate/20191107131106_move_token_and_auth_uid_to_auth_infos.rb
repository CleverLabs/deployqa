class MoveTokenAndAuthUidToAuthInfos < ActiveRecord::Migration[5.2]
  class User < ActiveRecord::Base
    has_one :auth_info
  end

  class AuthInfo < ActiveRecord::Base
    belongs_to :user
    enum provider: ["github", "gitlab"]
  end

  def up
    User.find_each do |user|
      user.auth_info.update!(uid: user.auth_uid, token: user.token, provider: user.auth_provider)
    end
  end

  def down
    AuthInfo.find_each do |auth_info|
      auth_info.update!(uid: nil, token: nil, provider: nil)
    end
  end
end
