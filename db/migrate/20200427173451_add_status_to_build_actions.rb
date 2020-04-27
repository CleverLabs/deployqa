class AddStatusToBuildActions < ActiveRecord::Migration[5.2]
  BuildAction = Class.new(ActiveRecord::Base)

  def up
    safety_assured do
      add_column :build_actions, :status, :integer

      BuildAction.find_each do |build_action|
        puts build_action.id
        build_action.update!(status: 2) # success
      end

      change_column_null :build_actions, :status, false
    end
  end

  def down
    remove_column :build_actions, :status
  end
end
