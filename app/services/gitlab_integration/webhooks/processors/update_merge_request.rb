# frozen_string_literal: true

module GitlabIntegration
  module Webhooks
    module Processors
      class UpdateMergeRequest
        def initialize(body)
          @merge_request = GitlabIntegration::Wrappers::MergeRequest.new(body)
        end

        def call
          return ReturnValue.ok unless repository.active?

          project_instance = repository.project.project_instances.find_by(attached_pull_request_number: @merge_request.number)
          Deployment::Processes::UpdateProjectInstance.new(project_instance, user_reference(@merge_request.edited_by_id)).call
          ReturnValue.ok
        end

        private

        def user_reference(auth_user_id)
          ::UserReference.find_or_create_by!(auth_provider: ProjectsConstants::Providers::GITLAB, auth_uid: auth_user_id) do |user_reference|
            user_reference.full_name = @merge_request.user_name
          end
        end

        def repository
          @_repository ||= Repository.find_by(integration_id: @merge_request.repo_id, integration_type: ProjectsConstants::Providers::GITLAB)
        end
      end
    end
  end
end
