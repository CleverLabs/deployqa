# frozen_string_literal: true

module Deployment
  module Processes
    class DestroyProjectInstance
      def initialize(project_instance, current_user)
        @project_instance = project_instance
        @current_user = current_user
      end

      def call
        return if @project_instance.deployment_status.in?([ProjectInstanceConstants::DESTROYED, ProjectInstanceConstants::CLOSED, ProjectInstanceConstants::CLOSED_NEVER_CREATED])
        return update_status if @project_instance.deployment_status.in?(ProjectInstanceConstants::NOT_DEPLOYED_INSTANCES)

        configurations = Deployment::ConfigurationBuilders::ByProjectInstance.new(@project_instance).call.map(&:to_h)
        build_action = BuildAction.create!(project_instance: @project_instance, author: @current_user, action: BuildActionConstants::DESTROY_INSTANCE)
        ServerActionsCallJob.perform_later(Deployment::ServerActions::Destroy.to_s, configurations, build_action)
      end

      private

      def update_status
        @project_instance.update(deployment_status: closed_status)
      end

      def closed_status
        return ProjectInstanceConstants::CLOSED_NEVER_CREATED if @project_instance.deployment_status == ProjectInstanceConstants::EMPTY_RECORD_FOR_PR

        ProjectInstanceConstants::CLOSED
      end
    end
  end
end
