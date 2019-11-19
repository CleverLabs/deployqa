class FillAuthInfoUserReferenceId  < ActiveRecord::Migration[5.2]
  UserReference = Class.new(ActiveRecord::Base)
  AuthInfo = Class.new(ActiveRecord::Base)

  def up
    user_references = UserReference.where(user_id: AuthInfo.pluck(:user_id)) # Load all records at once, since there is small amount of them

    AuthInfo.find_each do |auth_info|
      user_reference = user_references.find { |reference| reference.user_id == auth_info.user_id }
      auth_info.update!(user_reference_id: user_reference.id)
    end
  end

  def down
    AuthInfo.find_each do |auth_info|
      auth_info.update!(user_reference_id: nil)
    end
  end
end
