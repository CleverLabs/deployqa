# frozen_string_literal: true

module ProjectInstances
  class ReloadsController < ApplicationController
    def create
      @project = find_project
      @project_instance = @project.project_instances.find(params[:project_instance_id])
      configurations = Deployment::ConfigurationBuilder.new.by_project_instance(@project_instance)
      ServerActionsCallJob.perform_later(Deployment::ServerActions::Restart.to_s, configurations.map(&:to_h))
      redirect_to project_project_instance_path(@project, @project_instance)
    end

    def find_project
      Project.find(params[:project_id])
    end
  end
end
