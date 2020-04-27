class MigrateProjectInstancesToNewStatuses < ActiveRecord::Migration[5.2]
  STATUSES_MAPPING = {
    0 => 5,
    1 => 0,
    2 => 1,
    3 => 2,
    4 => 2,
    5 => 2,
    6 => 4,
    7 => 2,
    8 => 3,
    9 => 3,
    10 => 6
  }.freeze

  ProjectInstance = Class.new(ActiveRecord::Base)

  def change
    ProjectInstance.find_each do |project_instance|
      puts project_instance.id

      project_instance.update!(deployment_status: STATUSES_MAPPING.fetch(project_instance.deployment_status))
    end
  end
end
