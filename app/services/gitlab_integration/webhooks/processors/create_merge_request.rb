# frozen_string_literal: true

module GitlabIntegration
  module Webhooks
    module Processors
      class CreateMergeRequest
        def initialize(body)
          @merge_request = GitlabIntegration::Wrappers::MergeRequest.new(body)
        end

        def call
          return ReturnValue.ok unless repository.active?

          result = create_project_instance
          create_deployment_links(result)
          ReturnValue.ok
        end

        private

        def create_project_instance
          name = "mr#{@merge_request.number}"
          branches = { @merge_request.repo_name => @merge_request.branch }

          ::Deployment::Processes::CreateAttachedProjectInstance.new(repository.project).call(
            project_instance_name: name,
            branches: branches,
            attached_pull_request_number: @merge_request.number,
            attached_repo_path: @merge_request.full_repo_name
          )
        end

        def create_deployment_links(result)
          comment = Notifications::Comment.new(result.object)
          text = result.ok? ? comment.header : comment.failure_header

          GitlabIntegration::MergeRequest.new(repository.integration_id, @merge_request.number).update_description(text)
        end

        def repository
          @_repository ||= Repository.find_by(integration_id: @merge_request.repo_id, integration_type: ProjectsConstants::Providers::GITLAB)
        end
      end
    end
  end
end
