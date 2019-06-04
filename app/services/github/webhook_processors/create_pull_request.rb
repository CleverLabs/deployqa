# frozen_string_literal: true

module Github
  module WebhookProcessors
    class CreatePullRequest
      def initialize(body, project)
        @wrapped_body = Github::Events::CreatePullRequest.new(payload: body)
        @project = project
      end

      def call
        name = "pr#{@wrapped_body.number}"
        branches = { @wrapped_body.repo_name => @wrapped_body.branch }
        Deployment::Processes::CreateProjectInstance.new(@project, nil).call(project_instance_name: name, branches: branches, deploy: false).tap do |result|
          create_deployment_links(result)
        end
      end

      private

      def create_deployment_links(result)
        comment = Notifications::Comment.new(result.object)
        text = result.ok? ? comment.header : comment.failure_header
        Github::PullRequest.new(@wrapped_body.full_repo_name, @wrapped_body.number).add_to_first_comment(text)
      end
    end
  end
end
