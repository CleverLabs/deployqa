class FillAuthInfoEmail < ActiveRecord::Migration[5.2]
  AuthInfo = Class.new(ActiveRecord::Base)

  def up
    AuthInfo.find_each do |auth_info|
      auth_info.update!(email: auth_info.data["email"])
    end
  end

  def down
    AuthInfo.find_each do |auth_info|
      auth_info.update!(email: nil)
    end
  end
end
