# frozen_string_literal: true

module Deployment
  module Processes
    class UpdateProjectInstance
      def initialize(project_instance, current_user)
        @project_instance = project_instance
        @current_user = current_user
      end

      def call
        return unless @project_instance.deployment_status.in?(ProjectInstanceConstants::ACTIVE_INSTANCES)

        configurations = Deployment::ConfigurationBuilders::ByProjectInstance.new(@project_instance).call.map(&:to_h)
        build_action = BuildAction.create!(project_instance: @project_instance, author: @current_user, action: BuildActionConstants::UPDATE_INSTANCE)
        ServerActionsCallJob.perform_later(Deployment::ServerActions::Update.to_s, configurations, build_action)
      end
    end
  end
end
