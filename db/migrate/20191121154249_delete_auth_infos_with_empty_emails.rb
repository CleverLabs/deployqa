class DeleteAuthInfosWithEmptyEmails < ActiveRecord::Migration[5.2]
  User = Class.new(ActiveRecord::Base)
  UserReference = Class.new(ActiveRecord::Base)
  AuthInfo = Class.new(ActiveRecord::Base)
  ProjectUserRole = Class.new(ActiveRecord::Base)

  def up
    AuthInfo.where(email: nil).find_in_batches do |auth_infos_batch|
      users_ids = auth_infos_batch.map(&:user_id)
      UserReference.where(user_id: users_ids).update_all(user_id: nil)
      ProjectUserRole.where(user_id: users_ids).destroy_all
      AuthInfo.where(user_id: users_ids).destroy_all
      User.where(id: users_ids).destroy_all
    end
  end

  def down
    # Irreversible migration
  end
end
