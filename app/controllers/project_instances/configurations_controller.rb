# frozen_string_literal: true

module ProjectInstances
  class ConfigurationsController < ApplicationController
    layout "application_new"

    def edit
      @project = find_project
      @project_instance = find_project_instance(@project)
      @project_instance_policy = ProjectInstancePolicy.new(current_user, @project_instance)
    end

    def update
      @project = find_project
      @project_instance = find_project_instance(@project)

      Deployment::Processes::UpdateProjectInstanceConfiguration
        .new(@project_instance, current_user.user_reference)
        .call(configurations_to_update: configurations_to_update)
      redirect_to project_project_instance_path(@project, @project_instance)
    end

    private

    def find_project
      authorize ProjectDomain.by_id(params[:project_id]), :show?, policy_class: ProjectPolicy
    end

    def configurations_params
      params.require(:project_instance).require(:configurations).permit!
    end

    def find_project_instance(project)
      authorize project.project_instance(id: params[:project_instance_id]), :edit?, policy_class: ProjectInstancePolicy
    end

    def configurations_to_update
      configurations_params.to_h.transform_values do |env_variables|
        { env_variables: Hash[env_variables.values.map { |key_value| [key_value["key"], key_value["value"]] }].compact }
      end
    end
  end
end
