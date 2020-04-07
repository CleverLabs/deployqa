# frozen_string_literal: true

module Github
  module Webhooks
    module Processors
      class CreatePullRequest
        def initialize(body)
          @wrapped_body = Github::Events::PullRequest.new(payload: body)
          @project = ::ProjectDomain.by_integration(ProjectsConstants::Providers::GITHUB, @wrapped_body.installation_id)
        end

        def call
          return ReturnValue.ok unless @project.active_repository?(@wrapped_body.full_repo_name)

          result = create_project_instance
          create_deployment_links(result)
          ReturnValue.ok
        end

        private

        def create_project_instance
          name = "pr#{@wrapped_body.number}"
          branches = { @wrapped_body.repo_name => @wrapped_body.branch }

          Deployment::Processes::CreateAttachedProjectInstance.new(@project).call(
            project_instance_name: name,
            branches: branches,
            attached_pull_request_number: @wrapped_body.number,
            attached_repo_path: @wrapped_body.full_repo_name
          )
        end

        def create_deployment_links(result)
          comment = Notifications::Comment.new(result.object)
          text = result.ok? ? comment.header : comment.failure_header

          Github::PullRequest.new(@project.integration_id, @wrapped_body.full_repo_name, @wrapped_body.number).add_to_first_comment(text)
        end
      end
    end
  end
end
