# frozen_string_literal: true

module Deployment
  class ProjectInstanceEvents
    COMMENT_MESSAGES = {
      deploying: ->(_comment) { "Deploying..." },
      updating: ->(_comment) { "Updating..." },
      running: ->(comment) { comment.deployed },
      failure: ->(comment) { comment.failed },
      not_deployed: ->(_comment) { "Not deployed" },
      destroying: ->(_comment) { "Destroying..." },
      destroyed: ->(_comment) { "Application has been destroyed" }
    }.freeze

    COMMENT_TYPES = {
      BuildActionConstants::CREATE_INSTANCE.to_s => { start: :deploying, success: :running, failure: :not_deployed },
      BuildActionConstants::RECREATE_INSTANCE.to_s => { start: :deploying, success: :running, failure: :not_deployed },
      BuildActionConstants::UPDATE_INSTANCE.to_s => { start: :updating, success: :running, failure: :failure },
      BuildActionConstants::RELOAD_INSTANCE.to_s => { start: :updating, success: :running, failure: :running },
      BuildActionConstants::DESTROY_INSTANCE.to_s => { start: :destroying, success: :destroyed, failure: :failure }
    }.freeze

    INSTANCE_STATUSES = {
      BuildActionConstants::CREATE_INSTANCE.to_s => {
        start: ProjectInstanceConstants::Statuses::CREATING, success: ProjectInstanceConstants::Statuses::RUNNING, failure: ProjectInstanceConstants::Statuses::FAILED_TO_CREATE
      },
      BuildActionConstants::RECREATE_INSTANCE.to_s => {
        start: ProjectInstanceConstants::Statuses::CREATING, success: ProjectInstanceConstants::Statuses::RUNNING, failure: ProjectInstanceConstants::Statuses::FAILED_TO_CREATE
      },
      BuildActionConstants::UPDATE_INSTANCE.to_s => {
        start: :no_change, success: ProjectInstanceConstants::Statuses::RUNNING, failure: :no_change
      },
      BuildActionConstants::RELOAD_INSTANCE.to_s => {
        start: :no_change, success: ProjectInstanceConstants::Statuses::RUNNING, failure: :no_change
      },
      BuildActionConstants::DESTROY_INSTANCE.to_s => {
        start: :no_change, success: ProjectInstanceConstants::Statuses::TERMINATED, failure: ProjectInstanceConstants::Statuses::RUNNING
      }
    }.freeze

    BUILD_ACTION_STATUSES = {
      start: BuildActionConstants::Statuses::RUNNING,
      success: BuildActionConstants::Statuses::SUCCESS,
      failure: BuildActionConstants::Statuses::FAILURE
    }.freeze

    def initialize(build_action)
      @build_action = build_action
      @project_instance = build_action.project_instance
      @comment_types = COMMENT_TYPES.fetch(build_action.action)
      @instance_statuses = INSTANCE_STATUSES.fetch(build_action.action)
      @message_policy = ProjectInstanceMessagePolicy.new(nil, @project_instance)
    end

    def create_event(event)
      update_status!(event.to_sym)

      comment_type = @comment_types.fetch(event.to_sym)
      comment = Notifications::Comment.new(@project_instance)
      text = COMMENT_MESSAGES.fetch(comment_type).call(comment)

      Deployment::PullRequestNotificator.new(@project_instance).call(text) if @message_policy.pull_request_comments?
      Slack::Notificator.new(@project_instance).send_message(text) if @message_policy.slack?
    end

    private

    def update_status!(event)
      @build_action.update!(status: BUILD_ACTION_STATUSES.fetch(event))

      instance_status = @instance_statuses.fetch(event)
      return if instance_status == :no_change

      ProjectInstanceDomain.new(record: @project_instance).update_status!(instance_status)
    end
  end
end
