class FillIntegrationFieldsWithArbitraryValues < ActiveRecord::Migration[5.2]
  def up
    Project.where(integration_id: nil, integration_type: nil).find_each do |project|
      project.update_columns(integration_id: "EMPTY_#{SecureRandom.hex(4)}", integration_type: "EMPTY")
    end

    DeploymentConfiguration.where(integration_id: nil, integration_type: nil).find_each do |deployment_configuration|
      deployment_configuration.update_columns(integration_id: "EMPTY_#{SecureRandom.hex(4)}", integration_type: "EMPTY", status: "active")
    end
  end
end
