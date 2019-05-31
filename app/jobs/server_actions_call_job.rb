# frozen_string_literal: true

class ServerActionsCallJob < ApplicationJob
  def perform(class_name, configurations, serialized_logger, project_instance, performing_status)
    deserialized_configurations = configurations.map { |configuration| Deployment::Configuration.new(configuration) }
    deserialized_logger = BuildActionLogger.deserialize(serialized_logger)

    project_instance.update(deployment_status: performing_status)
    result_status = class_name.constantize.new(deserialized_configurations, deserialized_logger).call

    update_project_instance(project_instance, result_status)
  end

  private

  def update_project_instance(instance, status)
    instance.configurations.each { |conf| conf["application_url"] = heroku_app_url(conf["application_name"]) } if status != Constants::ProjectInstance::FAILURE

    instance.deployment_status = status
    instance.save!
  end

  def heroku_app_url(app_name)
    "https://#{app_name}.herokuapp.com"
  end
end
