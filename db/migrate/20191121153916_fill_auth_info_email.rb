class FillAuthInfoEmail < ActiveRecord::Migration[5.2]
  AuthInfo = Class.new(ActiveRecord::Base)

  DUMMY_EMAIL = "user_had_no_email_before_migration@deployqa.dev"

  def up
    AuthInfo.find_each do |auth_info|
      email = auth_info.data["email"] || DUMMY_EMAIL
      auth_info.update!(email: email)
    end
  end

  def down
    AuthInfo.find_each do |auth_info|
      auth_info.update!(email: nil)
    end
  end
end
