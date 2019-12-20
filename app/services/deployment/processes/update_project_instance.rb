# frozen_string_literal: true

module Deployment
  module Processes
    class UpdateProjectInstance
      def initialize(project_instance, user_reference)
        @project_instance = project_instance
        @user_reference = user_reference
      end

      def call
        return unless @project_instance.deployment_status.in?(ProjectInstanceConstants::ACTIVE_INSTANCES)

        configurations = Deployment::ConfigurationBuilders::ByProjectInstance.new(@project_instance).call.map(&:to_h)
        build_action = BuildAction.create!(project_instance: @project_instance, author: @user_reference, action: BuildActionConstants::UPDATE_INSTANCE)
        ServerActionsCallJob.perform_later(Deployment::ServerActions::Update.to_s, configurations, build_action)
      end
    end
  end
end
