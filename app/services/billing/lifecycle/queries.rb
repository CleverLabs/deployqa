# frozen_string_literal: true

module Billing
  module Lifecycle
    class Queries
      ZERO_TIME = DateTime.new(2018)

      def initialize(project)
        @project = project.project_record
      end

      def active_instances(last_invoice)
        scope = last_invoice ? last_invoice.project_instances : @project.project_instances
        scope.where(deployment_status: ProjectInstanceConstants::Statuses::ALL_ACTIVE)
      end

      def build_actions_by_project_instance(timeframe)
        BuildAction
          .joins(:project_instance)
          .where(project_instances: { project_id: @project.id }, end_time: timeframe.start..timeframe.end)
          .order(:end_time)
          .includes(:project_instance)
          .group_by(&:project_instance_id)
      end

      def previous_successful_build_action_for(build_action)
        previous_actions_for(build_action.project_instance, end_time: build_action.end_time)
          .where.not(id: build_action.id)
          .last
      end

      def previous_actions_for(project_instance, end_time:)
        project_instance
          .build_actions
          .where(end_time: ZERO_TIME..end_time, status: BuildActionConstants::Statuses::SUCCESS)
          .order(:end_time)
      end

      def invoices_for_period(timeframe)
        ::Invoice
          .where(project_id: @project.id)
          .where(end_time: timeframe.start..Float::INFINITY, start_time: ZERO_TIME..timeframe.end)
      end
    end
  end
end
