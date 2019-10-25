# frozen_string_literal: true

module ProjectInstances
  class AddonsController < ApplicationController
    def index
      @project = find_project
      @project_instance = @project.project_instances.find(params[:project_instance_id])
      @addons_per_app = @project_instance.configurations.each_with_object({}) do |configuration, object|
        object[configuration.application_name] = configuration.addons
      end
    end

    private

    def find_project
      authorize Project.find(params[:project_id]), :show?, policy_class: ProjectPolicy
    end
  end
end
