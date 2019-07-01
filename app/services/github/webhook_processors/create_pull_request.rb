# frozen_string_literal: true

module Github
  module WebhookProcessors
    class CreatePullRequest
      def initialize(body)
        @wrapped_body = Github::Events::PullRequest.new(payload: body)
        @project = Project.find_by(integration_type: ProjectsConstants::Providers::GITHUB, integration_id: @wrapped_body.installation_id)
      end

      def call
        name = "pr#{@wrapped_body.number}"
        branches = { @wrapped_body.repo_name => @wrapped_body.branch }
        Deployment::Processes::CreateAttachedProjectInstance.new(@project, nil).call(project_instance_name: name, branches: branches, pull_request_number: @wrapped_body.number).tap do |result|
          create_deployment_links(result)
        end
      end

      private

      def create_deployment_links(result)
        comment = Notifications::Comment.new(result.object)
        text = result.ok? ? comment.header : comment.failure_header
        Github::PullRequest.new(@project.integration_id, @wrapped_body.full_repo_name, @wrapped_body.number).add_to_first_comment(text)
        Slack::Notificator.new(@project).send_message("#{result.object.name} Deployed")
      end
    end
  end
end
