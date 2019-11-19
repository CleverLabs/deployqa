class UpdateBuildActionAuthorIdByUserReferenceId  < ActiveRecord::Migration[5.2]
  UserReference = Class.new(ActiveRecord::Base)
  BuildAction = Class.new(ActiveRecord::Base)

  def up
    user_references = UserReference.where(user_id: BuildAction.pluck(:author_id)).to_a # Load all records at once, since there is small amount of them

    BuildAction.find_each do |build_action|
      user_reference = user_references.find { |reference| reference.user_id == build_action.author_id }
      build_action.update(author_id: user_reference.id)
    end
  end

  def down
    # Irreversible migration
  end
end
