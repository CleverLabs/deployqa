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

    SLACK_EVENTS = [ProjectInstanceConstants::RUNNING, ProjectInstanceConstants::FAILURE].freeze

    def initialize(project_instance)
      @project_instance = project_instance
      @project = project_instance.project
    end

    def create_event(event)
      comment = Notifications::Comment.new(@project_instance)
      text = COMMENT_MESSAGES.fetch(event).call(comment)

      @project_instance.update!(deployment_status: event)
      update_pull_request_info_comment(text)
      Slack::Notificator.new(@project).send_message(text) if SLACK_EVENTS.include?(event)
    end

    private

    def update_pull_request_info_comment(text)
      return if @project.integration_type != ProjectsConstants::Providers::GITHUB || pull_request.blank?

      pull_request.update_info_comment(text)
    end

    def pull_request
      @_pull_request ||= begin
        pr_params = [@project.integration_id, @project_instance.attached_repo_path, @project_instance.attached_pull_request_number]
        return if pr_params.any?(&:blank?)

        Github::PullRequest.new(*pr_params)
      end
    end
  end
end
