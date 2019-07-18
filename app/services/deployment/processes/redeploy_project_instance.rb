# frozen_string_literal: true

module Deployment
  module Processes
    class RedeployProjectInstance
      def initialize(project_instance, current_user)
        @project_instance = project_instance
        @current_user = current_user
      end

      def call
        configurations = Deployment::ConfigurationBuilder.new.by_project_instance(@project_instance).map(&:to_h)
        build_action = BuildAction.create!(project_instance: @project_instance, author: @current_user, action: BuildActionConstants::RECREATE_INSTANCE)
        ServerActionsCallJob.perform_later(Deployment::ServerActions::Recreate.to_s, configurations, build_action)
      end
    end
  end
end
