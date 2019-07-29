class FillSystemRoleOnUsers < ActiveRecord::Migration[5.2]
  class User < ActiveRecord::Base
    enum system_role: %w(user, admin)
  end

  def up
    User.find_each do |user|
      user.update_columns(system_role: "user")
    end
  end
end
