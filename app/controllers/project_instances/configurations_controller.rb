# frozen_string_literal: true

module ProjectInstances
  class ConfigurationsController < ApplicationController
    def edit
      @project = find_project
      @project_instance = find_project_instance(@project)
    end

    def update
      @project = find_project
      @project_instance = find_project_instance(@project)

      if update_project_instance
        Deployment::Processes::ReloadProjectInstance.new(@project_instance, current_user).call
        redirect_to project_project_instance_path(@project, @project_instance)
      else
        render :edit
      end
    end

    private

    def find_project
      authorize Project.find(params[:project_id]), :show?, policy_class: ProjectPolicy
    end

    def configurations_params
      params.require(:project_instance).require(:configurations).permit!
    end

    def find_project_instance(project)
      authorize project.project_instances.find(params[:project_instance_id]), :edit?, policy_class: ProjectInstancePolicy
    end

    def update_project_instance
      configurations_params.each do |application_name, env_variables|
        configuration = @project_instance.configurations.find { |configuration_to_find| configuration_to_find.application_name == application_name }
        configuration.env_variables = Hash[env_variables.split("\n").map { |line| line.tr("\r", "").split("=") }]
      end

      @project_instance.save
    end
  end
end
