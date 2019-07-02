# frozen_string_literal: true

module ProjectInstances
  class BuildActionsController < ApplicationController
    def show
      @project = find_project
      @project_instance = @project.project_instances.find(params[:project_instance_id])
      @build_action = @project_instance.build_actions.find(params[:id])
    end

    private

    def find_project
      authorize Project.find(params[:project_id]), :show?, policy_class: ProjectPolicy
    end
  end
end
