# frozen_string_literal: true

module ProjectInstances
  class ReloadsController < ApplicationController
    def create
      project = find_project
      project_instance = find_project_instance(project)
      configurations = Deployment::ConfigurationBuilder.new.by_project_instance(project_instance)
      build_action = BuildAction.create!(project_instance: project_instance, author: current_user, action: BuildActionConstants::RELOAD_INSTANCE)
      ServerActionsCallJob.perform_later(Deployment::ServerActions::Restart.to_s, configurations.map(&:to_h), build_action)
      redirect_to project_project_instance_path(project, project_instance)
    end

    private

    def find_project
      authorize Project.find(params[:project_id]), :show?, policy_class: ProjectPolicy
    end

    def find_project_instance(project)
      authorize project.project_instances.find(params[:project_instance_id]), :reload?, policy_class: ProjectInstancePolicy
    end
  end
end
