class UpdateProjectInstanceConfigurations < ActiveRecord::Migration[5.2]
  ProjectInstance = Class.new(ActiveRecord::Base)

  def up
    ProjectInstance.find_each do |instance|
      new_configurations = instance.configurations.map do |configuration|
        new_configuration = configuration.except(:deployment_configuration_id)
        new_configuration[:repository_id] = configuration[:deployment_configuration_id]
        new_configuration
      end

      instance.update!(configurations: new_configurations)
    end
  end

  def down
    ProjectInstance.find_each do |instance|
      new_configurations = instance.configurations.map do |configuration|
        new_configuration = configuration.except(:repository_id)
        new_configuration[:deployment_configuration_id] = configuration[:repository_id]
        new_configuration
      end

      instance.update!(configurations: new_configurations)
    end
  end
end
