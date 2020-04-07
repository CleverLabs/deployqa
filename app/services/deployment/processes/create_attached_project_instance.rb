# frozen_string_literal: true

module Deployment
  module Processes
    class CreateAttachedProjectInstance
      def initialize(project)
        @project = project
      end

      def call(project_instance_name:, branches:, attached_repo_path:, attached_pull_request_number:)
        ProjectInstanceDomain.create(
          project_id: @project.id,
          name: project_instance_name,
          deployment_status: ProjectInstanceConstants::EMPTY_RECORD_FOR_PR,
          attached_repo_path: attached_repo_path,
          attached_pull_request_number: attached_pull_request_number,
          branches: branches
        )
      end
    end
  end
end
