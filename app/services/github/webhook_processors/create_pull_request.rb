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
        Deployment::Processes::CreateProjectInstance.new(@project, nil).call(project_instance_name: name, branches: branches, deploy: false)
      end
    end
  end
end
