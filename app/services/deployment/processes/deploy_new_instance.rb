# frozen_string_literal: true

module Deployment
  module Processes
    class DeployNewInstance
      def initialize(project_instance)
        @project_instance = project_instance
        @features_accessor = Features::Accessor.new
      end

      def call(user_reference)
        Deployment::Helpers::RefreshProjectInstanceConfiguration.new(
          @project_instance,
          ->() { @features_accessor.docker_deploy_allowed?(user_reference.user, @project_instance.project) }
        ).call
        configurations = Deployment::ConfigurationBuilders::ByProjectInstance.new(@project_instance).call
        build_action = BuildAction.create!(project_instance: @project_instance, author: user_reference, action: BuildActionConstants::CREATE_INSTANCE)

        if @features_accessor.docker_deploy_allowed?(user_reference.user, @project_instance.project)
          @features_accessor.perform_docker_deploy!(@project_instance)
          Robad::Executor.new(build_action).call(configurations)
        else
          ServerActionsCallJob.perform_later(Deployment::ServerActions::Create.to_s, configurations.map(&:to_h), build_action)
        end
      end
    end
  end
end
