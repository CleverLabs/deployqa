# frozen_string_literal: true

module ProjectInstances
  class UpdatesController < ApplicationController
    def create
      project = find_project
      project_instance = project.project_instances.find(params[:project_instance_id])

      Deployment::Processes::UpdateProjectInstance.new(project_instance, current_user).call
      redirect_to project_project_instance_path(project, project_instance)
    end

    def find_project
      Project.find(params[:project_id])
    end
  end
end
