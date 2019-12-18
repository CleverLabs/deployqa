class UpdateBuildActionAuthorIdByUserReferenceId  < ActiveRecord::Migration[5.2]
  UserReference = Class.new(ActiveRecord::Base)
  BuildAction = Class.new(ActiveRecord::Base)

  def up
    user_references = UserReference.where(user_id: BuildAction.pluck(:author_id)).to_a # Load all records at once, since there is small amount of them

    user_references.each do |user_reference|
      BuildAction.where(author_id: user_reference.user_id).update_all(author_id: user_reference.id)
    end
  end

  def down
    # Irreversible migration
  end
end
