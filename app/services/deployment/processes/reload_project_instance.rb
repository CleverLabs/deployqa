# frozen_string_literal: true

module Deployment
  module Processes
    class ReloadProjectInstance
      def initialize(project_instance, user_reference)
        @project_instance = project_instance
        @user_reference = user_reference
      end

      def call
        configurations = Deployment::ConfigurationBuilders::ByProjectInstance.new(@project_instance).call.map(&:to_h)
        build_action = BuildAction.create!(project_instance: @project_instance, author: @user_reference, action: BuildActionConstants::RELOAD_INSTANCE)
        ServerActionsCallJob.perform_later(Deployment::ServerActions::Restart.to_s, configurations, build_action)
      end
    end
  end
end
