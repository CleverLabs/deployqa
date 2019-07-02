# frozen_string_literal: true

module Deployment
  module Processes
    class CreateAttachedProjectInstance
      def initialize(project, current_user)
        @project = project
        @current_user = current_user
      end

      def call(project_instance_name:, branches:, pull_request_number:)
        configurations = Deployment::ConfigurationBuilder.new.by_project(@project, project_instance_name, branches: branches)
        Deployment::Repositories::ProjectInstanceRepository.new(@project).create(
          name: project_instance_name,
          pull_request_number: pull_request_number,
          deployment_status: ProjectInstanceConstants::EMPTY_RECORD_FOR_PR,
          configurations: configurations.map(&:to_project_instance_configuration)
        )
      end

      private

      attr_reader :current_user
    end
  end
end
