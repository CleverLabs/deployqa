# frozen_string_literal: true

module ProjectInstances
  class UpdatesController < ApplicationController
    def create
      project = find_project
      project_instance = find_project_instance(project)

      Deployment::Processes::UpdateProjectInstance.new(project_instance, current_user).call
      redirect_to project_project_instance_path(project, project_instance)
    end

    private

    def find_project
      authorize Project.find(params[:project_id]), :show?, policy_class: ProjectPolicy
    end

    def find_project_instance(project)
      authorize project.project_instances.find(params[:project_instance_id]), :update_server?, policy_class: ProjectInstancePolicy
    end
  end
end
