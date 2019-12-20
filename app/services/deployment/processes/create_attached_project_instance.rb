# frozen_string_literal: true

module Deployment
  module Processes
    class CreateAttachedProjectInstance
      def initialize(project)
        @project = project
      end

      def call(project_instance_name:, branches:, attached_repo_path:, attached_pull_request_number:)
        configurations = Deployment::ConfigurationBuilders::ByProject.new(@project).call(project_instance_name, branches)
        Deployment::Repositories::ProjectInstanceRepository.new(@project).create(
          name: project_instance_name,
          attached_repo_path: attached_repo_path,
          attached_pull_request_number: attached_pull_request_number,
          configurations: configurations.map(&:to_project_instance_configuration),
          deployment_status: ProjectInstanceConstants::EMPTY_RECORD_FOR_PR
        )
      end
    end
  end
end
