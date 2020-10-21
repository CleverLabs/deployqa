# frozen_string_literal: true

module ProjectInstances
  class BuildActionsController < ApplicationController
    def show
      @project = find_project
      @project_instance = @project.project_instance(id: params[:project_instance_id])
      @build_action = @project_instance.build_actions.find(params[:id])
      @build_action_logs = @build_action.build_action_logs.order(created_at: :desc)
      @project_instance_policy = ProjectInstancePolicy.new(current_user, @project_instance)
    end

    private

    def find_project
      authorize ProjectDomain.by_id(params[:project_id]), :show?, policy_class: ProjectPolicy
    end
  end
end
