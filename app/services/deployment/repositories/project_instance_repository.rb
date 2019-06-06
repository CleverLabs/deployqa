# frozen_string_literal: true

module Deployment
  module Repositories
    class ProjectInstanceRepository
      Result = Struct.new(:object, :status)

      def initialize(project, project_instance = :no_project_instance)
        @project = project
        @project_instance = project_instance
      end

      def create(name, pull_request_number, configurations)
        object = @project.project_instances.create(deployment_status: :scheduled, name: name, pull_request_number: pull_request_number, configurations: configurations)
        ReturnValue.new(object: object, status: object.errors.any? ? :error : :ok)
      end

      def update(deployment_status:)
        ReturnValue.new(object: @project_instance, status: @project_instance.update(deployment_status: deployment_status) ? :error : :ok)
      end
    end
  end
end
