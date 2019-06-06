# frozen_string_literal: true

module Github
  module WebhookProcessors
    class UpdatePullRequest
      def initialize(body, project)
        @wrapped_body = Github::Events::PullRequest.new(payload: body)
        @project = project
      end

      def call
        project_instance = @project.project_instances.find_by(number: @wrapped_body.number)
        Deployment::Processes::UpdateProjectInstance.new(project_instance, nil).call.tap do |result|
          update_info_comment(result)
        end
      end

      private

      def update_info_comment(result)
        comment = Notifications::Comment.new(result.object)
        text = result.ok? ? comment.deployed : comment.failed
        Github::PullRequest.new(@wrapped_body.full_repo_name, @wrapped_body.number).update_info_comment(text)
      end
    end
  end
end
