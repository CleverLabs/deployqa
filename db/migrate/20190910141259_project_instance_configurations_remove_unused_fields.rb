class ProjectInstanceConfigurationsRemoveUnusedFields < ActiveRecord::Migration[5.2]
  ProjectInstance = Class.new(ActiveRecord::Base)

  def up
    ProjectInstance.find_each do |instance|
      new_configs = instance.configurations.map { |config| config.except("deployment_configuration_id") }
      instance.update!(configurations: new_configs)
    end
  end

  def down
    # Irreversible migration
  end
end
