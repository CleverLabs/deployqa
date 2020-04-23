# frozen_string_literal: true

module GitlabIntegration
  module Webhooks
    module Processors
      class CloseMergeRequest
        def initialize(body)
          @merge_request = GitlabIntegration::Wrappers::MergeRequest.new(body)
        end

        def call
          ReturnValue.ok unless repository.active?

          project_instance = find_project_instance
          return ReturnValue.ok unless project_instance

          project_instance = ProjectInstanceDomain.new(record: project_instance)
          Deployment::Processes::DestroyProjectInstance.new(project_instance, user_reference(@merge_request.author_id)).call if project_instance
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

        def find_project_instance
          repository.project.project_instances.find_by(attached_pull_request_number: @merge_request.number)
        end
      end
    end
  end
end
