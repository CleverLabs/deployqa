# frozen_string_literal: true

module Deployment
  module Processes
    class CreateProjectInstance
      def initialize(project, current_user)
        @project = project
        @current_user = current_user
      end

      def call(project_instance_name:, branches: {}, pull_request_number: nil, deploy: true)
        configurations = Deployment::ConfigurationBuilder.new.by_project(@project, project_instance_name, branches: branches)
        creation_result = Deployment::Repositories::ProjectInstanceRepository.new(@project).create(project_instance_name, pull_request_number, configurations.map(&:to_project_instance_configuration))
        return creation_result unless creation_result.ok?

        deploy_instance(creation_result.object, configurations) if deploy
        creation_result
      end

      private

      attr_reader :current_user

      def deploy_instance(instance, configurations)
        build_action = BuildAction.create!(project_instance: instance, author: current_user, action: BuildActionConstants::CREATE_INSTANCE)
        ServerActionsCallJob.perform_later(Deployment::ServerActions::Create.to_s, configurations.map(&:to_h), build_action)
      end
    end
  end
end
