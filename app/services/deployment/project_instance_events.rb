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

    def initialize(project_instance)
      @project_instance = project_instance
      @project = project_instance.project
      @message_policy = ProjectInstanceMessagePolicy.new(nil, @project_instance)
    end

    def create_event(event)
      comment = Notifications::Comment.new(@project_instance)
      text = COMMENT_MESSAGES.fetch(event).call(comment)

      @project_instance.update!(deployment_status: event)
      update_pull_request_info_comment(text) if @message_policy.github_comments?
      Slack::Notificator.new(@project_instance).send_message(text) if @message_policy.slack?
    end

    private

    def update_pull_request_info_comment(text)
      pull_request = Github::PullRequest.new(@project.integration_id, @project_instance.attached_repo_path, @project_instance.attached_pull_request_number)
      pull_request.update_info_comment(text)
    end
  end
end
