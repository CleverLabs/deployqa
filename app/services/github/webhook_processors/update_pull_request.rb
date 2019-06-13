# frozen_string_literal: true

module Github
  module WebhookProcessors
    class UpdatePullRequest
      def initialize(body)
        @wrapped_body = Github::Events::PullRequest.new(payload: body)
        @project = Project.find_by(integration_type: Github::User::PROVIDER, github_installation_id: @wrapped_body.installation_id)
      end

      def call
        project_instance = @project.project_instances.find_by(pull_request_number: @wrapped_body.number)
        Deployment::Processes::UpdateProjectInstance.new(project_instance, nil).call.tap do |result|
          update_info_comment(result, project_instance)
        end
      end

      private

      def update_info_comment(result, project_instance)
        comment = Notifications::Comment.new(project_instance)
        text = result.ok? ? comment.deployed : comment.failed
        Github::PullRequest.new(@project.github_installation_id, @wrapped_body.full_repo_name, @wrapped_body.number).update_info_comment(text)
      end
    end
  end
end
