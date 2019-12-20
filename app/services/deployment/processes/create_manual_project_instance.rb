# frozen_string_literal: true

module Deployment
  module Processes
    class CreateManualProjectInstance
      def initialize(project, user_reference)
        @project = project
        @user_reference = user_reference
      end

      def call(project_instance_name:, branches:)
        configurations = Deployment::ConfigurationBuilders::ByProject.new(@project).call(project_instance_name, branches)
        creation_result = create_project_instance(project_instance_name, configurations)
        return creation_result unless creation_result.ok?

        deploy_instance(creation_result.object, configurations)
        creation_result
      end

      private

      def create_project_instance(project_instance_name, configurations)
        Deployment::Repositories::ProjectInstanceRepository.new(@project).create(
          name: project_instance_name,
          configurations: configurations.map(&:to_project_instance_configuration),
          deployment_status: ProjectInstanceConstants::SCHEDULED
        )
      end

      def deploy_instance(instance, configurations)
        build_action = BuildAction.create!(project_instance: instance, author: @user_reference, action: BuildActionConstants::CREATE_INSTANCE)
        ServerActionsCallJob.perform_later(Deployment::ServerActions::Create.to_s, configurations.map(&:to_h), build_action)
      end
    end
  end
end
