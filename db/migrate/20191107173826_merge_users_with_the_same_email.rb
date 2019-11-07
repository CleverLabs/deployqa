class MergeUsersWithTheSameEmail < ActiveRecord::Migration[5.2]
  User = Class.new(ActiveRecord::Base)
  AuthInfo = Class.new(ActiveRecord::Base)
  ProjectUserRole = Class.new(ActiveRecord::Base)

  def up
    User.pluck(:email).uniq.each do |email|
      users_ids = User.where(email: email).order(system_role: :desc, id: :asc).ids
      main_user_id = users_ids.shift

      AuthInfo.where(user_id: users_ids).find_each do |auth_info|
        auth_info.update!(user_id: main_user_id)
      end

      ProjectUserRole.where(user_id: users_ids).find_each do |project_user_role|
        project_user_role.update!(user_id: main_user_id)
      end

      User.where(id: users_ids).destroy_all
    end
  end

  def down
    # Irreversible migration
  end
end
