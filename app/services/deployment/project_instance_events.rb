# frozen_string_literal: true

module Deployment
  class ProjectInstanceEvents
    COMMENT_MESSAGES = {
      ProjectInstanceConstants::DEPLOYING => ->(_comment) { "Deploying..." },
      ProjectInstanceConstants::UPDATING => ->(_comment) { "Updating..." },
      ProjectInstanceConstants::RUNNING => ->(comment) { comment.deployed },
      ProjectInstanceConstants::FAILURE => ->(comment) { comment.failed },
      ProjectInstanceConstants::NOT_DEPLOYED => ->(_comment) { "Not deployed" },
      ProjectInstanceConstants::DESTROYING => ->(_comment) { "Destroying..." },
      ProjectInstanceConstants::DESTROYED => ->(_comment) { "Application has been destroyed" }
    }.freeze

    def initialize(build_action)
      @project_instance = build_action.project_instance
      @statuses = ProjectInstanceConstants::ACTION_STATUSES.fetch(build_action.action)
      @message_policy = ProjectInstanceMessagePolicy.new(nil, @project_instance)
    end

    def create_event(event)
      status = @statuses.fetch(event.to_sym)
      comment = Notifications::Comment.new(@project_instance)
      text = COMMENT_MESSAGES.fetch(status).call(comment)

      @project_instance.update!(deployment_status: status)
      Deployment::PullRequestNotificator.new(@project_instance).call(text) if @message_policy.pull_request_comments?
      Slack::Notificator.new(@project_instance).send_message(text) if @message_policy.slack?
    end
  end
end
