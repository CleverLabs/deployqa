class MoveUsersGithubEntitiyToAuthInfo < ActiveRecord::Migration[5.2]
  AuthInfo = Class.new(ActiveRecord::Base)
  GithubEntity = Class.new(ActiveRecord::Base)

  def up
    GithubEntity.where(owner_type: "User").find_each do |entity|
      AuthInfo.create!(user_id: entity.owner_id, data: entity.data)
      entity.destroy
    end
  end

  def down
    # Irreversible
  end
end
