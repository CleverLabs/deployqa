# frozen_string_literal: true

module Deployment
  module Repositories
    class ProjectInstanceRepository
      Result = Struct.new(:object, :status)

      def initialize(project, project_instance = :no_project_instance)
        @project = project
        @project_instance = project_instance
      end

      def create(name:, configurations:, attached_repo_path: nil, attached_pull_request_number: nil, deployment_status: nil)
        object = @project.project_instances.create(
          deployment_status: deployment_status,
          name: name,
          attached_repo_path: attached_repo_path,
          attached_pull_request_number: attached_pull_request_number,
          configurations: configurations
        )
        ReturnValue.new(object: object, status: object.errors.any? ? :error : :ok)
      end

      def update(deployment_status:)
        ReturnValue.new(object: @project_instance, status: @project_instance.update(deployment_status: deployment_status) ? :error : :ok)
      end
    end
  end
end
