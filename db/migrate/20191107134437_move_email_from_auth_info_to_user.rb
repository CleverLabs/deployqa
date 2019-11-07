class MoveEmailFromAuthInfoToUser < ActiveRecord::Migration[5.2]
  class User < ActiveRecord::Base
    has_one :auth_info
  end

  class AuthInfo < ActiveRecord::Base
    belongs_to :user
  end

  def up
    User.find_each do |user|
      user.update!(email: user.auth_info.data["email"])
    end
  end

  def down
    user.update!(email: nil)
  end
end
