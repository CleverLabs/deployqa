class MoveConfigurationsToBuildAction < ActiveRecord::Migration[5.2]
  BuildAction = Class.new(ActiveRecord::Base)
  ProjectInstance = Class.new(ActiveRecord::Base)

  def up
    BuildAction.find_each do |build_action|
      puts build_action.id

      build_action.configurations = ProjectInstance.find(build_action.project_instance_id).configurations
      build_action.save!
    end
  end
end
